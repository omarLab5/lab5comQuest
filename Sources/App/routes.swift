import Vapor
import Authentication
import Crypto
/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example

    struct InfoData: Content {
        let name: String
    }

    // Example of configuring a controller
    let questController = QuestController()
    try questController.boot(router: router)
    
    let usersController = UserController()
    try usersController.boot(router: router)
    
    let mediaController = MediaController()
    try mediaController.boot(router: router)

    let questionController = QuestionController()
    try questionController.boot(router: router)

    
    let answerController = AnswerController()
    try answerController.boot(router: router)

    let answerInfoController = InfoAnswerQuestionController()
    try answerInfoController.boot(router: router)
    
    let participationQuest = ParticipationController()
    try participationQuest.boot(router: router)
    
    
    let infoQuestQuestion = QuestQuestionInfoController()
    try infoQuestQuestion.boot(router: router)
    
}

