# JokeTeller-Combine-CoreML

## Personal Objectives
- Use the Combine framework to get familiar with the Declarative Approach
- Since I do not have Apple Dev Account to test camera stuff, To illustrate the video/image stream. I use my webcam as streamed data.
- CoreML for image detection. Saving the name of the detected object to find a joke about it. (I wanted to use object detection as well but my Mac is quite old)
- Using WebSocket to get the image data stream.
- [UICollectionViewCompositionalLayout](https://developer.apple.com/documentation/uikit/uicollectionviewcompositionallayout) and [UICollectionViewDiffableDataSource](https://developer.apple.com/documentation/uikit/uicollectionviewdiffabledatasource) to have new iOS 13+ available Modern CollectionView.
- To complete and get familiar with the [Modern UICollectionView](https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/implementing_modern_collection_views) completely, Using iOS 14+ available CellRegistration at minimum.
- in iOS 15+ [UISheetPresentationController](https://developer.apple.com/documentation/uikit/uisheetpresentationcontroller) is served with only two detents which are medium and large, in iOS 16 Beta, [Custom Detent](https://developer.apple.com/documentation/swiftui/presentationdetent/custom(_:)?changes=__6) option is served and used in this project.
- Creating custom components such as RandeSlider and [PLAlert](https://github.com/baris-cakmak/PLAlert). Check the Components folder under Utils
- Use CABasicAnimation and CALayers to have colorful loading indicators and understand how third-party libraries work.
- Implementing Alamofire and its recommendation of [Router Patern](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#routing-requests) to have a generic Network Layer. Also, to see how Alamofire uses Combine as an extension.
- Using a Property Wrapper for UserDefaults to solve the repetition across the codebase.
- Creating custom transition for presenting and dismissal Also, using UIViewControllerInteractiveTransitioning for user interactive transition such as Apple Photos App(hiding the image that is presented).
- Making "Animator Controllers" to make Transition Reusable and follow Single Responsibility. Check Animators Folder under the Utils Folder

## Usage
- To get the image stream and start the detection, Run the python script that is located in the Server Folder(do not forget to replace your IP address).
- When the WebSocket server is ready to be connected, simply click the connect button. For the rest, check the "Overview" section which shows the Demo.
## Third Parties
- [PLAlert](https://github.com/baris-cakmak/PLAlert) is a simple Alert Controller that I have developed especially for this project. I have also experienced Dependency Management through this process.
- [Alamofire](https://github.com/Alamofire/Alamofire) is used in this project to see the Router pattern.
- [Starscream](https://github.com/daltoniam/Starscream) is used to handle the image data stream from a Weboscket Service.

## Screenshots
<p align= "center">
<img src="https://user-images.githubusercontent.com/96867747/187521288-312a14d4-6179-4c76-9f0b-582192a91ef2.png" width="30%">
<img src="https://user-images.githubusercontent.com/96867747/187521299-0a43bcaf-0ed4-42ec-854e-1f5c755b3560.png" width="30%">
</p>

## Overview
https://user-images.githubusercontent.com/96867747/187536258-4bd5a808-d484-44fe-93a0-d1ed5dcd49e6.mp4
