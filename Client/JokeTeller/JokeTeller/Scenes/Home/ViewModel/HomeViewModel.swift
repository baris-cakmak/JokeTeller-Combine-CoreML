import Foundation
import Combine
import CoreImage

enum HomeSection {
    case main
}

protocol HomeViewModelInterface {
    func viewDidLoad()
    func didConnectTapped()
    func didTellMeAJokeTapped()
    func didStopStreamTapped()
    func didWebSocketUrlStringRequested(_ urlString: String)
    var inferenceDescriptionText: String? { get }
    var coreMLModel: VNCoreMLModelReturnable? { get set }
    var imageToBeClassified: CIImage { get }
    var imageToBeClassifiedPublisher: Published<CIImage>.Publisher { get }
    var snapshotInferenceOutputPublisher: AnyPublisher<HomeSnapshot, Never> { get }
    var inferenceOutputSettingsSubject: CurrentValueSubject<InferenceOutputSetings, Never> { get }
    var connectionButtonTextPublisher: Published<String>.Publisher { get }
    var connectionStatusPublisher: CurrentValueSubject<ConnectionStatus, Never> { get }
    var imageDataSubject: CurrentValueSubject<Data, Never> { get }
    var errorMessageToBeShown: CurrentValueSubject<String, Never> { get }
    var successMessageToBeShown: CurrentValueSubject<String, Never> { get }
    var jokeToBeShown: PassthroughSubject<JokeDetailModel, Never> { get }
    var showIndicatorSubject: CurrentValueSubject<Bool, Never> { get }
}

final class HomeViewModel: HomeViewModelInterface {
    // MARK: - Properties
    @Published var imageToBeClassified: CIImage = .init()
    @Published var connectionButtonText: String = "Connect"
    @Published var inferenceOuputs: [String] = [""]
    @Published var coreMLModel: VNCoreMLModelReturnable?
    var imageDataSubject: CurrentValueSubject<Data, Never> = .init(.init())
    var inferenceDescriptionText: String?
    var inferenceOutputSettingsSubject: CurrentValueSubject<InferenceOutputSetings, Never> = .init(.init())
    var connectionStatusPublisher: CurrentValueSubject<ConnectionStatus, Never> = .init(.disconnected)
    var imageToBeClassifiedPublisher: Published<CIImage>.Publisher { $imageToBeClassified }
    var connectionButtonTextPublisher: Published<String>.Publisher { $connectionButtonText }
    var errorMessageToBeShown: CurrentValueSubject<String, Never> = .init("")
    var successMessageToBeShown: CurrentValueSubject<String, Never> = .init("")
    var jokeToBeShown: PassthroughSubject<JokeDetailModel, Never> = .init()
    var showIndicatorSubject: CurrentValueSubject<Bool, Never> = .init(false)
    private var cancellables: Set<AnyCancellable> = .init()
    private let websocketService: WebsocketServiceInterface?
    private let coreMLService: CoreMLServiceInterface?
    private let jokeApiService: JokeApiServiceInterface?
    @Stroge(key: .webscoketUrlString)
    private var savedWebSocketUrl: String?
    var snapshotInferenceOutputPublisher: AnyPublisher<HomeSnapshot, Never> {
        $inferenceOuputs.map { outputs in
            var snapshot = HomeSnapshot()
            snapshot.appendSections([.main])
            snapshot.appendItems(outputs)
            return snapshot
        }
        .eraseToAnyPublisher()
    }
    // MARK: - Init
    init(
        websocketService: WebsocketServiceInterface,
        coreMLService: CoreMLService,
        coreMLModel: VNCoreMLModelReturnable?,
        jokeApiService: JokeApiServiceInterface
    ) {
        self.websocketService = websocketService
        self.coreMLService = coreMLService
        self.coreMLModel = coreMLModel
        self.jokeApiService = jokeApiService
    }
}
// MARK: - Method
extension HomeViewModel {
    func viewDidLoad() {
        guard let coreMLModel = coreMLModel,
            var request = coreMLService?.requestMLModel(coreMLModel, with: inferenceOutputSettingsSubject.value) else {
            return
        }
        inferenceOutputSettingsSubject
            .combineLatest($coreMLModel)
            .sink { [weak self] inferenceConfidenceSetting, model in
                guard let self = self,
                    let coreMLService = self.coreMLService,
                    let model = model else {
                    return
                }
                request = coreMLService.requestMLModel(model, with: inferenceConfidenceSetting)
            }
            .store(in: &cancellables)
        websocketService?
            .dataPublisher
            .dropFirst()
            .throttle(for: .milliseconds(50), scheduler: DispatchQueue.main, latest: true)
            .map { data -> CIImage in
                self.imageDataSubject.send(data)
                return .data(data)
            }
            .sink { [weak self] ciImage in
                self?.imageToBeClassified = ciImage
            }
            .store(in: &cancellables)
        imageToBeClassifiedPublisher
            .dropFirst()
            .sink { [weak self] ciImage in
                self?.coreMLService?.performRequest(request, with: ciImage)
            }
            .store(in: &cancellables)
        coreMLService?
            .inferenceOutputPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] inferenceOutputs in
                self?.inferenceOuputs = inferenceOutputs
            }
            .store(in: &cancellables)
        websocketService?
            .websocketErrorSubject
            .sink { [weak self] error in
                self?.errorMessageToBeShown.send(error.localizedDescription)
            }
            .store(in: &cancellables)
    }
    func didConnectTapped() {
        if let savedWebSocketUrl = savedWebSocketUrl {
            websocketService?.setWebsocketUrl(urlString: savedWebSocketUrl)
        }
        websocketService?.connect()
        websocketService?
            .connectionStatusPublisher
            .sink { [weak self] status in
                self?.connectionStatusPublisher.send(status)
            }
            .store(in: &cancellables)
        websocketService?
            .connectionStatusPublisher
            .map { status in
                status.titleCased
            }
            .sink { [weak self] statusDescription in
                self?.connectionButtonText = statusDescription
            }
            .store(in: &cancellables)
    }
    func didTellMeAJokeTapped() {
        self.showIndicatorSubject.send(true)
        coreMLService?
            .inferenceDescriptionSubject
            .sink { [weak self] wordToSearch in
                self?.inferenceDescriptionText = wordToSearch
            }
            .store(in: &cancellables)
        guard let inferenceDescriptionText = inferenceDescriptionText else {
            self.errorMessageToBeShown.send("No Detected Values")
            self.showIndicatorSubject.send(false)
            return
        }
        jokeApiService?.searchJoke(keyword: inferenceDescriptionText) { resultPublisher in
            resultPublisher
                .delay(for: .microseconds(1000), scheduler: DispatchQueue.main)
                .sink { [weak self] result in
                    self?.showIndicatorSubject.send(false)
                    switch result {
                    case .success(let jokeResponseModel):
                        if let joke = jokeResponseModel.jokes.first,
                           let imageData = self?.imageDataSubject.value {
                            self?.jokeToBeShown.send(.init(jokeModel: joke, imageData: imageData))
                        }

                    case .failure(let error):
                        self?.errorMessageToBeShown.send(error.localizedDescription)
                    }
                }
                .store(in: &self.cancellables)
        }
    }
    func didStopStreamTapped() {
        websocketService?.disconnect()
    }
    func didWebSocketUrlStringRequested(_ urlString: String) {
        websocketService?.setWebsocketUrl(urlString: urlString) { result in
            switch result {
            case .success(let urlStringMessageToShow):
                self.successMessageToBeShown.send("\(urlStringMessageToShow) is Set")
                self.savedWebSocketUrl = urlString

            case .failure(let error):
                self.errorMessageToBeShown.send(error.localizedDescription)
            }
        }
    }
}
