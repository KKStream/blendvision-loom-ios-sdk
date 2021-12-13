# BlendVisionLoomPlayer iOS SDK

BlendVisionLoomPlayer is a Swift library to help you integrate BlendVision Loom player into your iOS app.

## Trying the Sample App

To have a quick look at the features of BlendVisionLoomPlayer SDK, try our sample app by following the steps below

1. Clone or download this repository.
2. Open the `sample/BlendVisionLoomPlayerSample.xcodeproj` file in Xcode.
3. Build and run the `BlendVisionLoomPlayerSample` scheme.

## Using the SDK

### Minimum Requirements

- Xcode 13.1
- iOS 12.0 (latest 3 versions)
- Swift 5.0

> **Note**
> 
> BlendVisionLoomPlayer will drop support for older OS three months after the latest version is officially released by Apple. 
> For example, iOS 13 was released on `Sep 19, 2019`, then iOS 10 support would be dropped after `Dec 20, 2019`.   

### Installation

To use BlendVisionLoomPlayer within your app, following the steps below

1. Copy ALL framework files under the `frameworks` folder into your project folder.
2. Add your framework folder's path to "Build Settings > Framework Search Paths".
3. Add relevant frameworks to the "Frameworks, Libraries, and Embedded Content" section of "General" tab in your app target.
    - BlendVisionLoomPlayer.xcframework (Embed & Sign)
    - KKSPaaS.xcframework (Embed & Sign)
    - KKSNetwork.xcframework (Embed & Sign)
    - KKSLocalization.xcframework (Embed & Sign)
4. Make sure GoogleCast.framework and GoogleInteractiveMediaAds.framework are NOT added to
   "Frameworks, Libraries, and Embedded Content" but exist in the framework folder mentioned in step 2.

## Sample Code

### Video Content

```swift
import BlendVisionLoomPlayer

let content = VideoContent(id: "VIDEO_CONTENT_ID",
                           title: "VIDEO_TITLE",
                           startTime: 0,
                           source: VideoContent.Source(url: VIDEO_SOURCE_URL,
                                                       thumbnailUrl: VIDEO_THUMBNAIL_URL),
                           drm: VideoContent.DRM(licenseUrl: DRM_LICENSE_URL,
                                                 certificateUrl: DRM_CERTIFICATE_URL,
                                                 header: DRM_HEADER)
```

#### Content Protection

BlendVisionLoomPlayer supports content protection with DRM/DRM+ level. 
You can play videos with protection by configuring license URL, FairPlay certificate URL, and a custom header for your own business logic.

```swift
// Server-to-Server
let drm = VideoContent.DRM(licenseUrl: DRM_LICENSE_URL,
                           certificateUrl: DRM_CERTIFICATE_URL,
                           header: [ 
                               // custom keys and values
                               "X-SESSION-ID": "MEMBER_SESSION_ID",
                               ...
                           ])

// Client-to-Server (NOT RECOMMENDED)
let drm = VideoContent.DRM(licenseUrl: DRM_LICENSE_URL,
                           certificateUrl: DRM_CERTIFICATE_URL,
                           header: [
                               "Authorization": "Bearer {JWT}"
                           ])
```

### Player Context

```swift
// Create a player context with bar items
let context = PlayerContext(barItems: [.settings])
```

Use `PlayerContext.BarItem.custom(view: UIView?)` to configure custom bar item.

```swift
let someButton = UIButton()
// configure the button and its action
// ...
let context = PlayerContext(barItems: [.custom(view: someButton)])
```

### Player

#### Initialization

```swift
let player = LoomPlayer(context: PlayerContext(...),
                        contents: [VideoContent(...), ...],
                        startIndex: 0,
                        eventHandler: nil)
```

#### Customization

```swift
// Get player view.
let playerView = player.view

// Add player view onto other views.
view.addSubview(playerView)

// Layout player view.
playerView.widthAnchor.constraint(equalToConstant: 426).isActive = true
playerView.heightAnchor.constraint(equalToConstant: 240).isActive = true
```

#### Modal Presentation

BlendVisionLoomPlayer provides a quick way to present player modally with `UIModalPresentationStyle.fullScreen` in a specified view controller. It is recommanded that you use this function to present one player at a time.

```swift
// If `viewController` is `nil`, the top most view controller in the view hierarchy will be used.
Loom.shared.presentPlayer(context: PlayerContext(...),
                          contents: [VideoContent(...), ...],
                          startIndex: 0,
                          eventHandler: nil,
                          in: viewController,
                          completion: { player in
                              guard let player: LoomPlayer = player else { return }
                              
                              // Interact with player...
                          })
``` 

### Player Event Handling

`PlayerEventHandling` defines the methods that your handler implements to handle player events. To handle player events, you need to provide player an instance of a type that conforms to the `PlayerEventHandling` protocol.

```swift
// Define a handler that conforms to PlayerEventHandling.
class PlayerEventHandler: PlayerEventHandling {
    // Optional. Called when player did successfully load first video.
    func didLoad(_ player: LoomPlayer) {
        // Customized behaviors...
        // You can pause player here to prevent player from auto-play.
        player.pause()
    }

    // Optional. Called when player did play a video to the end.
    func didEndVideo(_ player: LoomPlayer, at index: Int) {
        // Customized behaviors...
        // You can call `seek(to: 0)` here to replay current video.
        player.seek(to: 0)
        
        // You can call `next()` here to play next video.
        player.next()
    }

    // Optional. Called when an error occurs.
    // If this method is not implemented, default error handling (e.g. showing alerts) will be performed.
    // `player` could be `nil` if error occurs before player is initialized.
    func didFail(_ player: LoomPlayer?, error: LoomError)  {
        // Customized behaviors...
    }

    // Optional. Called when a video event occurs for video tracking.
    func didReceiveVideoEvent(_ player: LoomPlayer?, videoEvent: VideoEvent) {
        // Customized behaviors...
        switch videoEvent {
        case .videoPlaybackBegan(let contentIndex, let position):
            break
        case .videoPlaybackEnded(let contentIndex, let position):
            break
        case .videoPlaybackStopped(let contentIndex, let playedDuration):
            break
        case .videoPlaybackErrorOccurred(let contentIndex, let position, let playbackError):
            break
        case .play(let contentIndex, let position):
            break
        case .pause(let contentIndex, let position):
            break
        case .rewind(let contentIndex, let position):
            break
        case .forward(let contentIndex, let position):
            break
        case .previousEpisode(let contentIndex, let position):
            break
        case .nextEpisode(let contentIndex, let position):
            break
        case .videoSeekingEnded(let contentIndex, let seekFrom, let seekTo):
            break
        case .settingPageEntered(let contentIndex):
            break
        case .settingPageExited(let contentIndex):
            break
        }
    }
}

// Provide the handler to player at initialization stage.
let handler = PlayerEventHandler()
let player = LoomPlayer(..., eventHandler: handler)
```

##### Note

To make sure your app can receive `.videoPlaybackEnded` event when app terminates, it is required to extend app's background execution time in `AppDelegate` (and/or `UISceneDelegate` if you support iOS 13 and later). For more details, please see [Apple Developer Documentation | Extending Your App's Background Execution Time](https://developer.apple.com/documentation/uikit/app_and_environment/scenes/preparing_your_ui_to_run_in_the_background/extending_your_app_s_background_execution_time).

```swift
// AppDelegate.swift
func applicationDidEnterBackground(_ application: UIApplication) {
    // Extend the app's background execution time.
    // Perform the task on a background queue.
    DispatchQueue.global().async {
        // Request the task assertion and save the ID.
        self.backgroundTaskId = UIApplication.shared.beginBackgroundTask {
            // End the task if time expires.
            UIApplication.shared.endBackgroundTask(self.backgroundTaskId!)
            self.backgroundTaskId = UIBackgroundTaskIdentifier.invalid
        }
        
        // Do your task here...
        // ...

        // End the task assertion.
        self.backgroundTaskId = UIBackgroundTaskIdentifier.invalid
        UIApplication.shared.endBackgroundTask(self.backgroundTaskId!)
    }
}

// SceneDelegate.swift
func sceneDidEnterBackground(_ scene: UIScene) {
    // Extend the app's background execution time.
    // Perform the task on a background queue.
    DispatchQueue.global().async {
        // Request the task assertion and save the ID.
        self.backgroundTaskId = UIApplication.shared.beginBackgroundTask {
            // End the task if time expires.
            UIApplication.shared.endBackgroundTask(self.backgroundTaskId!)
            self.backgroundTaskId = UIBackgroundTaskIdentifier.invalid
        }
        
        // Do your task here...
        // ...

        // End the task assertion.
        self.backgroundTaskId = UIBackgroundTaskIdentifier.invalid
        UIApplication.shared.endBackgroundTask(self.backgroundTaskId!)
    }
}
```

#### Error

`LoomError` passed to `PlayerEventHandler.didFail(_ : , error:)` was defined as below. 

```swift
enum LoomError: Error {
    struct PlaybackError: Error {
        var code: String
    }

    // Please refer to the playback error document for more details.
    case playback(PlaybackError)

    case startIndexOutOfRange
    case emptyVideoContents
    case invalidWindowHierarchy
}
```

### Playback Control

Control playback through `LoomPlayer`.
 
```swift
player.play()

player.pause()

player.rewind()

player.forward()

player.previous()

player.next()

player.seek(to: seconds)

player.mute()

player.unmute()
```

### UI Control

```swift
// Show control panel including playback controls and progress bar.
// This function also enables automatically showing or hiding control panel when a tap event is detected.
player.showPlaybackControlsAndProgressBar()

// Hide control panel including playback controls and progress bar.
// This function also disables automatically showing or hiding control panel when a tap event is detected.
player.hidePlaybackControlsAndProgressBar()
```

### Fullscreen and Autorotation

```swift
// A Bool for if player is currently in fullscreen mode.
// If player is presented through `Loom.shared.presentPlayer()`, this value will always return `false`.
player.isFullscreen

// Enter fullscreen mode with autorotate enabled/disabled.
// This method will do nothing if it is called when there is an existing player in fullscreen mode.
player.enterFullscreen(autoRotate: autoRotateEnabled)

// Exit fullscreen mode.
player.exitFullscreen()
```

> **_⚠️ Fullscreen mode is not supported when the player is presented modally._**

To disable autorotation when player is in fullscreen, you need extra configuration in `AppDelegate`. Use `RotationHelper.lockedOrientationMask` to get player's desired locked orientation.

```swift
// AppDelegate.swift
func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    // Return locked orientation mask if player's autorotate is disabled.
    RotationHelper.lockedOrientationMask ?? .all
}
```

### Background Playback

To enable background playback, make sure you turned on the Background Modes capability for your app and had "Audio, AirPlay, and Picture in Picture" option checked. For more details, please see [Apple Developer Documentation | Enabling Background Audio](https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/creating_a_basic_video_player_ios_and_tvos/enabling_background_audio).

```swift
// The default value is `false`.
player.isBackgroundPlaybackEnabled = true
```
