import APIBuilder

extension Paged {
    public var first: APIEndpoint<Paged<T>>? {
        self.pageLinks["first"]
    }

    public var next: APIEndpoint<Paged<T>>? {
        self.pageLinks["next"]
    }

    public var prev: APIEndpoint<Paged<T>>? {
        self.pageLinks["prev"]
    }

    public var last: APIEndpoint<Paged<T>>? {
        self.pageLinks["last"]
    }
}
