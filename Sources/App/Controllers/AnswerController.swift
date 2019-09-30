import Vapor


final class AnswerController: RouteCollection {
    
    func getAllHandler(_ req: Request) throws -> Future<[Answer]> {
        return Answer.query(on: req).decode(Answer.self).all()
    }
    func getOneHandler(_ req: Request) throws -> Future<Answer> {
        return try req.parameters.next(Answer.self)
    }
    
    
    
    
    
    func createHandler(_ req: Request) throws -> Future<Answer> {
        return try req.content.decode(Answer.self).flatMap { (quest) in
            return quest.save(on: req)
        }
    }
    
    
    
    func updateHandler(_ req: Request) throws -> Future<Answer> {
        return try flatMap(to: Answer.self, req.parameters.next(Answer.self), req.content.decode(Answer.self)) { (answer, updatedAnswer) in
            answer.answerTitle = updatedAnswer.answerTitle
            answer.answerSubject = updatedAnswer.answerSubject
            
            answer.userID = updatedAnswer.userID
            answer.mediaID = updatedAnswer.mediaID
            
            return answer.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Answer.self).flatMap { (answer) in
            return answer.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
    
    
    func getUserHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(Answer.self).flatMap(to: User.Public.self) { (answer) in
            return answer.user.get(on: req).toPublic()
        }
    }
    
    
 
    func getInfosHandler(_ req: Request) throws -> Future<[InfoAnswerQuestion]> {
        return try req.parameters.next(Answer.self).flatMap(to: [InfoAnswerQuestion].self) { (answer) in
            return try answer.infos.query(on: req).all()
        }
    }
    
        //GET ANSWERS
        func getAnswersQuestHandler(_ req: Request) throws -> Future<[Answer]> {
            return Answer.query(on: req).decode(Answer.self).all()
        }
    
    
    
    

   
    func boot(router: Router) throws {
        
        let questRoute = router.grouped("api", "answer")
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenProtected = questRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenProtected.get(use: getAllHandler)
        tokenProtected.get(Answer.parameter, use: getOneHandler)
        tokenProtected.post(use: createHandler)
        tokenProtected.put(Answer.parameter, use: updateHandler)
        tokenProtected.delete(Answer.parameter, use: deleteHandler)
        //GET : api/question/questId/user
        tokenProtected.get(Answer.parameter, "user", use: getUserHandler)

    
        //GET api/answer/infos
        tokenProtected.get(Answer.parameter,"infos", use : getInfosHandler)
    }
}

