import Vapor

final class MediaController: RouteCollection {
    
    func getAllHandler(_ req: Request) throws -> Future<[Media]> {
        return Media.query(on: req).decode(Media.self).all()
    }
    func getOneHandler(_ req: Request) throws -> Future<Media> {
        return try req.parameters.next(Media.self)
    }
    
    func createHandler(_ req: Request) throws -> Future<Media> {
        return try req.content.decode(Media.self).flatMap { (media) in
            return media.save(on: req)
        }
    }
    func updateHandler(_ req: Request) throws -> Future<Media> {
        return try flatMap(to: Media.self, req.parameters.next(Media.self), req.content.decode(Media.self)) { (media, updatedMedia) in
            media.mediaTitle = updatedMedia.mediaTitle
            media.mediaDescription = updatedMedia.mediaDescription
            return media.save(on: req)
        }
    }
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Media.self).flatMap { (media) in
            return media.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
    
    
   
    
    func boot(router: Router) throws {
        let mediasRoute = router.grouped("api", "media")
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenProtected = mediasRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenProtected.get(use: getAllHandler)
        tokenProtected.get(Media.parameter, use: getOneHandler)
        tokenProtected.post(use: createHandler)
        tokenProtected.put(Media.parameter, use: updateHandler)
        tokenProtected.delete(Media.parameter, use: deleteHandler)

    }

}
