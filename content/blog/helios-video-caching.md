---
title: 'Helios: Caching Video on iOS While It Plays'
description: 'How Helios caches video as it streams, with AVAssetResourceLoader, byte-range requests, and Swift actors. It runs in three Zomato apps with an 80% cache hit rate.'
publicationDate: '2026-10-12'
---

Short videos are everywhere in Zomato's apps: dish videos, stories, banners, and tutorials. Most people watch the same few videos more than once, often on slow mobile networks. Without a cache, every view downloads the whole video again, and every view starts with a spinner.

`AVPlayer` has no cache you can control. So I built **Helios**, named after the Greek god of the sun, a small Swift package that caches video **while it plays**. It started in the Zomato app and now runs in three apps, Zomato, District, and Hyperpure, with an **80% cache hit rate**.

This is how it works, and what I learned on the way.

## Why not download first, then play?

The simple version is to download the file, save it, and play it from disk. That has two problems:

- **The first view waits for the whole file.** Nobody waits for a full video to download before the first frame.
- **Most views do not finish.** People scroll away after a few seconds. Downloading the full file wastes data and storage.

What we want is to start playing as soon as the first bytes arrive, keep every byte that is downloaded, and continue from there next time. That is **partial caching**: a video that was watched halfway is half cached.

## The trick: a custom URL scheme

`AVPlayer` downloads `https` URLs itself, and gives you no access to the bytes. But for a URL it does not know how to load, it asks the delegate of the asset's `AVAssetResourceLoader` for the data.

So Helios changes the scheme of the URL:

```swift
// https://cdn.example.com/video.mp4 → helios://cdn.example.com/video.mp4
let asset = AVURLAsset(url: url.withScheme("helios"))
asset.resourceLoader.setDelegate(loader, queue: .main)
```

Now every read of the video goes through our code. AVFoundation asks for byte ranges, like "bytes 0 to 65,535", and Helios answers each one from the disk, from the network, or from both.

## Answering AVFoundation's requests

Each request from the resource loader has two parts:

1. **Content information:** the type of the file, its total length, and whether it supports byte ranges. Without these, playback does not start.
2. **A data request:** a requested offset and length, and a `currentOffset` that moves forward as you respond.

```swift
func fill(_ info: AVAssetResourceLoadingContentInformationRequest?) {
	info?.contentType = mimeType
	info?.contentLength = totalLength
	info?.isByteRangeAccessSupported = true
}

func respond(to request: AVAssetResourceLoadingDataRequest) -> Bool {
	let start = Int(request.currentOffset)
	guard cached.count > start else {
		return false
	}

	let end = min(cached.count, Int(request.requestedOffset) + request.requestedLength)
	request.respond(with: cached.subdata(in: start..<end))

	// Finished only when the whole requested range is served.
	return end == Int(request.requestedOffset) + request.requestedLength
}
```

Requests that cannot be served yet wait in a set. Each time more bytes arrive from the network, Helios goes through the waiting requests, responds with what it has, and finishes those that are complete. So the player starts as soon as the first range is there, and does not have to wait for the full file.

## Continuing where the last view stopped

When a video was partly watched before, its bytes are already on disk. Helios loads them, and then needs two things from the server: the full length of the file, and the bytes it does not have yet.

### The full length

A tiny request for the first two bytes is enough. The answer is a `206 Partial Content` response, and its `Content-Range` header has the full length after the slash:

```
Content-Range: bytes 0-1/48213760
```

Do not use `expectedContentLength` for this. For a `206` response, it is the length of the range, here 2 bytes, not of the file. AVFoundation needs the full length in the content information, or playback stops early.

```swift
extension HTTPURLResponse {
	/// The full length of the file, from `Content-Range: bytes 0-1/48213760`.
	var totalContentLength: Int64? {
		guard
			let range = value(forHTTPHeaderField: "Content-Range"),
			let total = range.split(separator: "/").last
		else {
			return expectedContentLength >= 0 ? expectedContentLength : nil
		}

		return Int64(total)
	}
}
```

If the cache already has all of it, there is no download at all, and a rewatched video starts instantly, even offline.

### The rest of the bytes

Otherwise, Helios asks only for what is missing:

```swift
var request = URLRequest(url: url)
request.setValue("bytes=\(cached.count)-", forHTTPHeaderField: "Range")

let task = session.dataTask(with: request) // The request, not the URL.
task.resume()
```

That last line matters more than it looks. `dataTask(with: url)` compiles just as well, and it silently drops the `Range` header. The server then sends the file from byte 0, and the new bytes are appended after the ones already cached, so the cached file has the start of the video twice. Nothing crashes, playback just breaks for videos that were partly watched, which is hard to trace back.

Two checks make this safe:

- **Check the status code.** A `206` means the server sent the requested range. A `200` means it ignored the `Range` header and is sending the whole file, so the cache has to start over instead of appending.
- **Check that the range starts where the cache ends.** The start of `Content-Range` should equal `cached.count`.

When the last byte arrives, the partial file becomes a complete file.

## Why a data task, not a download task?

`URLSession` has two ways to download a file, and a download task looks like the obvious choice for video: it writes to disk for you, can run in the background, and can resume. Helios uses a data task anyway, for four reasons.

**A download task does not give you the bytes until it is done.** Its delegate reports progress as numbers, and hands over the file only in `didFinishDownloadingTo`. The player needs the bytes as they arrive, to answer the requests of the resource loader. A data task delivers each chunk to `didReceive data` right away, so the first frame can play while the rest is still downloading.

**The file of a download task is not yours while it downloads.** It is a temporary file that `URLSession` owns, in a place it chooses, and it is deleted as soon as the delegate method returns. You cannot read from it halfway, so there is no partial file to play from or to keep.

**Resume data is not a partial cache.** A download task resumes with `cancel(byProducingResumeData:)`, but that data is an opaque blob for the same session to continue the same download. You cannot play from it, combine it with bytes you already have, or keep it in your own cache. With a data task, every byte that arrives is already in the cache, and a `Range` request continues from any point.

**Cancelling would throw the bytes away.** People scroll past most videos after a few seconds, so downloads are cancelled all the time. When a download task is cancelled without resume data, everything it downloaded is lost. When a data task stops, every byte it received is already saved.

The advantages of a download task are mostly about **background transfers**: a background session continues while the app is suspended, and writes straight to disk without holding the file in memory. That matters for large files the user downloads for later, like videos to watch offline. It does not matter for a video that is on screen right now. For that case, a data task gives Helios the bytes when it needs them, and full control over where they are kept.

## Two caches

**On disk**, each video is a file named by the SHA-256 hash of its URL, in the Caches directory. The total size has a limit. When a download finishes and the cache is over the limit, Helios removes the least recently used files first, by the date each file was last read. The system can also clear the Caches directory when it needs space, which is fine for a cache.

**In memory**, Helios keeps a small number of assets, each with its loader and its bytes. That lets a video that scrolls back into view continue right away. This cache is limited by count, also least recently used first. On a memory warning, it is emptied.

## Actors instead of locks

Video loading is very concurrent. The resource loader asks for data on one queue, `URLSession` delivers bytes on another, the disk is written on a third, and the screen needs progress updates on the main thread. With locks, that is a lot of ways to get it wrong.

Swift actors make it manageable:

- **Each video is an actor.** It owns its bytes, its waiting requests, and its download. Nothing outside can change them while it responds to a request.
- **The disk is an actor.** Writes for the same file are chained, so each one waits for the previous one. Chunks are appended in order, even when they arrive faster than the disk writes them.
- **The manager is an actor.** It owns the in-memory cache, and is the only way to get an asset.

`AVAssetResourceLoaderDelegate` and `URLSessionDataDelegate` are Objective-C protocols that need an `NSObject`, which an actor cannot be. A small helper object conforms to both, and sends each callback on to the actor.

## Prefetching and pausing

Two small APIs made a large difference in feeds:

- **Prefetch:** start downloading a video before it is on screen, like the next card in a list. When it scrolls into view, the first frames are already cached.
- **Pause and resume:** when a video scrolls off screen, its download stops, and continues from the same byte when it comes back. A prefetched video is not paused, as it is not on screen anyway.

## Built to be shared

Each app has its own needs, so Helios has a few small extension points:

- `Helios.configure(…)` sets the disk limit and the number of assets in memory, once at launch.
- A **caching provider** decides where the files go and how they are named.
- A **tracking delegate** reports how many bytes each video used, so the cache can be measured.
- The file system is behind a protocol, so the tests use a mock instead of the disk.

In the merchant app, it is behind a remote flag, so it can be turned off without a release.

## What I would do differently

- **Do not keep whole videos in memory.** Responding from an in-memory buffer is simple, but a long video takes a lot of memory. Reading the requested range from the file is better for large files.
- **Check what the cache contains.** If a file changes on the server under the same URL, a partial cache from the old file must not be combined with bytes from the new one. Store the `ETag`, and start over when it changes.
- **Test with a slow network from day one.** The bugs only show up when bytes arrive slower than the player reads them.

## Takeaways

1. **A custom URL scheme is how you get between AVPlayer and the network.** It is a documented, public API, not a hack.
2. **Cache what is downloaded, not only what is finished.** Partial caching is where the savings are.
3. **Trust the response, not the request.** Check for `206` and `Content-Range` before appending a single byte.
4. **Use actors for anything with more than one callback queue.** They remove a whole kind of bug.
5. **Measure the hit rate.** Without it, you only know that the cache exists, not that it helps.
