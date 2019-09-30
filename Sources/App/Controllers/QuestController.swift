import Vapor


final class QuestController: RouteCollection {
    
    func getAllHandler(_ req: Request) throws -> Future<[Quest]> {
        return Quest.query(on: req).decode(Quest.self).all()
    }
    func getOneHandler(_ req: Request) throws -> Future<Quest> {
        return try req.parameters.next(Quest.self)
    }
    
    func createHandler(_ req: Request) throws -> Future<Quest> {
        return try req.content.decode(Quest.self).flatMap { (quest) in
            return quest.save(on: req)
        }
    }
    func updateHandler(_ req: Request) throws -> Future<Quest> {
        return try flatMap(to: Quest.self, req.parameters.next(Quest.self), req.content.decode(Quest.self)) { (quest, updatedQuest) in
            quest.name = updatedQuest.name
            quest.username = updatedQuest.username
            quest.userID = updatedQuest.userID

            return quest.save(on: req)
        }
    }
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Quest.self).flatMap { (quest) in
            return quest.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
    
    
    func getUserHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(Quest.self).flatMap(to: User.Public.self) { (quest) in
            return quest.user.get(on: req).toPublic()
        }
    }
    
    

    
    func getQuestionsHandler(_ req: Request) throws -> Future<[QuestionInfos]> {
            return try req.parameters.next(Quest.self).flatMap{ (quest) in
                let infoQuestions = Question.query(on: req)
                    .join(\QuestQuestionInfo.questionID, to: \Question.id)
                    .filter(\QuestQuestionInfo.questID, .equal, quest.id!)
                    .alsoDecode(QuestQuestionInfo.self)
                    .all()

                return infoQuestions.map({ (data) -> ([QuestionInfos]) in
                    var questions = [QuestionInfos]()
                    for dataInfo in data{
                        var questionInfo = QuestionInfos(question: nil, infos: nil)
                        questionInfo.infos = dataInfo.1
                        questionInfo.question = dataInfo.0
                        questions.append(questionInfo)
                    }
                    return questions
                })
                
        }
    }
    

    
    func boot(router: Router) throws {
        let questRoute = router.grouped("api", "quests")
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenProtected = questRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenProtected.get(use: getAllHandler)
        tokenProtected.get(Quest.parameter, use: getOneHandler)
        tokenProtected.post(use: createHandler)
        tokenProtected.put(Quest.parameter, use: updateHandler)
        tokenProtected.delete(Quest.parameter, use: deleteHandler)
        //GET : api/quests/questId/user
        tokenProtected.get(Quest.parameter, "user", use: getUserHandler)
//        tokenProtected.get(Quest.parameter, "users", use: getUsersParticpationHandler)
        tokenProtected.get(Quest.parameter, "questions", use: getQuestionsHandler)
//        tokenProtected.post(Quest.parameter, "question", Question.parameter, use: addQuestionHandler)
    }
}
