import Vapor


final class QuestionController: RouteCollection {
    
    func getAllHandler(_ req: Request) throws -> Future<[Question]> {
        return Question.query(on: req).decode(Question.self).all()
    }
    func getOneHandler(_ req: Request) throws -> Future<Question> {
        return try req.parameters.next(Question.self)
    }
    
    
    func createHandler(_ req: Request) throws -> Future<Question> {
        return try req.content.decode(Question.self).flatMap { (quest) in
            return quest.save(on: req)
        }
    }
    
    
    func updateHandler(_ req: Request) throws -> Future<Question> {
        return try flatMap(to: Question.self, req.parameters.next(Question.self), req.content.decode(Question.self)) { (question, updatedQuestion) in
            question.title = updatedQuestion.title
            question.subject = updatedQuestion.subject
            
            question.userID = updatedQuestion.userID
            question.mediaID = updatedQuestion.mediaID
            
            return question.save(on: req)
        }
    }
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Question.self).flatMap { (quest) in
            return quest.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }

    

    func getUserHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(Question.self).flatMap(to: User.Public.self) { (quest) in
            return quest.user.get(on: req).toPublic()
        }
    }
    
    
    
    // return answers of the question
    func getAnswersHandler(_ req: Request) throws -> Future<[Answer]> {
        return try req.parameters.next(Question.self).flatMap{ (question) in
            return Answer.query(on: req)
            .filter(\InfoAnswerQuestion.questionID, .equal, question.id!)
            .join(\InfoAnswerQuestion.answerID, to: \Answer.id)
            .all()
        }
    }
    
    //get question/id/answer/id
    //get an answer of question by id
    func getAnswerOfQuestionByIdHandler(_ req: Request) throws -> Future<AnswersInfos> {
        return try flatMap(to: AnswersInfos.self, req.parameters.next(Question.self), req.parameters.next(Answer.self)){(question , answer) in
            let info = InfoAnswerQuestion.query(on: req).filter(\InfoAnswerQuestion.questionID, .equal, question.id!)
                       .filter(\InfoAnswerQuestion.answerID, .equal, answer.id!).first()
            return info.and(result:answer).map({ data -> (AnswersInfos) in
                let answerData = AnswersInfos(answer: answer, infos: data.0)
                        return answerData
            })
        }
    }
    
//    //GET ANSWERS OF QUESTION
    
    func getAnswersQuestHandler(_ req: Request) throws -> Future<[AnswersInfos]> {
            return try req.parameters.next(Question.self).flatMap{ (question) in
                let infoAnswe = Answer.query(on: req)
                    .join(\InfoAnswerQuestion.answerID, to: \Answer.id)
                    .filter(\InfoAnswerQuestion.questionID, .equal, question.id!)
                    .alsoDecode(InfoAnswerQuestion.self)
                    .all()
                return infoAnswe.map({ (data) -> ([AnswersInfos]) in
                var answers = [AnswersInfos]()

                for dataInfo in data{
                    var answerInfo = AnswersInfos(answer: nil , infos: nil)
                     answerInfo.infos = dataInfo.1
                     answerInfo.answer = dataInfo.0
                    answers.append(answerInfo)
                }
                return answers
                })
                
        }

    }

   
   
    
    
//    func removeAnswersHandler(_ req: Request) throws -> Future<HTTPStatus> {
//        return try flatMap(to: HTTPStatus.self, req.parameters.next(Question.self), req.parameters.next(Answer.self)) { (question, answer) in
//            return question.answers.detach(answer, on: req).transform(to: .noContent)
//        }
//    }
//
//
    
    
    //return InfoQuestion/answer

    func getInfosHandler(_ req: Request) throws -> Future<[InfoAnswerQuestion]> {
        return try req.parameters.next(Question.self).flatMap(to: [InfoAnswerQuestion].self) { (question) in
            return try question.infos.query(on: req).all()
        }
    }
    
    
    func boot(router: Router) throws {
        
        let questRoute = router.grouped("api", "question")
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenProtected = questRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenProtected.get(use: getAllHandler)
        tokenProtected.get(Question.parameter, use: getOneHandler)
        tokenProtected.post(use: createHandler)
        tokenProtected.put(Question.parameter, use: updateHandler)
        tokenProtected.delete(Question.parameter, use: deleteHandler)
        
        //GET : api/question/questId/user
        tokenProtected.get(Question.parameter, "user", use: getUserHandler)
        tokenProtected.get(Question.parameter, "answer",Answer.parameter , use: getAnswerOfQuestionByIdHandler)
        tokenProtected.get(Question.parameter, "answers" , use: getAnswersQuestHandler)
        
        //GET api/question/infos
        tokenProtected.get(Question.parameter,"infos", use : getInfosHandler)

    }
}
