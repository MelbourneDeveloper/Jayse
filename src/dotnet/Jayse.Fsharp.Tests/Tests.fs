namespace Jayse.Tests

    open Xunit
    open Jayse.JsonValue


    module JsonValueTests =

        // [<Fact>]
        // let ``Basic JSON to object`` () =
        //     let bookJson = """{"title": "The Great Gatsby", "author": "F. Scott Fitzgerald"}"""

        //     let book = JsonValueDecode bookJson :?> JsonObject
        //     let titleValue = book.["title"] :?> JsonString
        //     Assert.Equal("The Great Gatsby", titleValue.Value)
        //     Assert.Equal(JsonString "The Great Gatsby", book.["title"])
        //     Assert.Equal(JsonString "F. Scott Fitzgerald", book.["author"])

        // [<Fact>]
        // let ``Missing Value Test`` () =
        //     let bookJson = """{"title": "The Great Gatsby"}"""

        //     let book = JsonValueDecode bookJson :?> JsonObject
        //     let nameValue = book.["author"].["name"]
        //     Assert.Equal(Undefined(), nameValue)

        [<Fact>]
        let ``Some/None`` () =
            Assert.True((JsonString "").IsSome)
            Assert.False((JsonString "").IsNone)
            Assert.True((JsonString "a").IsSome)
            Assert.False((JsonString "a").IsNone)
            Assert.True((JsonNumber 0.0).IsSome)
            Assert.False((JsonNumber 0.0).IsNone)
            Assert.True((JsonNumber 1.0).IsSome)
            Assert.False((JsonNumber 1.0).IsNone)
            Assert.True((JsonBoolean false).IsSome)
            Assert.False((JsonBoolean false).IsNone)
            Assert.True((JsonBoolean true).IsSome)
            Assert.False((JsonBoolean true).IsNone)
            Assert.False(JsonNull.IsSome)
            Assert.True(JsonNull.IsNone)
            Assert.False(Undefined.IsSome)
            Assert.True(Undefined.IsNone)
            Assert.True((WrongType "a").IsSome)
            Assert.False((WrongType "a").IsNone)

        // [<Fact>]
        // let ``JsonValue fromJson string`` () =
        //     let json = "hello"
        //     let jsonValue = JsonValue.FromJson json
        //     Assert.IsType<JsonString>(jsonValue)
        //     Assert.Equal(json, (jsonValue :?> JsonString).Value)

        // [<Fact>]
        // let ``JsonValue fromJson int`` () =
        //     let json = 42
        //     let jsonValue = JsonValue.FromJson json
        //     Assert.IsType<JsonNumber>(jsonValue)
        //     Assert.Equal(float json, (jsonValue :?> JsonNumber).Value)

        // [<Fact>]
        // let ``JsonValue fromJson float`` () =
        //     let json = 3.14
        //     let jsonValue = JsonValue.FromJson json
        //     Assert.IsType<JsonNumber>(jsonValue)
        //     Assert.Equal(json, (jsonValue :?> JsonNumber).Value)

        // [<Fact>]
        // let ``JsonValue fromJson bool`` () =
        //     let json = true
        //     let jsonValue = JsonValue.FromJson json
        //     Assert.IsType<JsonBoolean>(jsonValue)
        //     Assert.Equal(json, (jsonValue :?> JsonBoolean).Value)

        [<Fact>]
        let ``JsonObject value returns correct map`` () =
            let value = Map [
                "name", JsonString "John"
                "age", JsonNumber 30.0
            ]
            let jsonObject = JsonObject value
            Assert.Equal(JsonObject value, jsonObject)

        // [<Fact>]
        // let ``JsonString value returns correct string`` () =
        //     let value = "hello"
        //     let jsonString = JsonString value
        //     Assert.Equal(value, jsonString.Value)

        // [<Fact>]
        // let ``JsonNumber value returns correct int`` () =
        //     let value = 42
        //     let jsonNumber = JsonNumber (float value)
        //     Assert.Equal(float value, jsonNumber.Value)

        // [<Fact>]
        // let ``JsonNumber value returns correct float`` () =
        //     let value = 3.14
        //     let jsonNumber = JsonNumber value
        //     Assert.Equal(value, jsonNumber.Value)

        // [<Fact>]
        // let ``JsonBoolean value returns correct bool`` () =
        //     let value = true
        //     let jsonBoolean = JsonBoolean value
        //     Assert.Equal(value, jsonBoolean.Value)

        [<Fact>]
        let ``JsonArray value returns correct list`` () =
            let value = [
                JsonString "one"
                JsonNumber 2.0
                JsonBoolean true
            ]
            let jsonArray = JsonArray value
            Assert.Equal<JsonValue list>(value, jsonArray.Value)

        // [<Fact>]
        // let ``JsonNull constructor creates instance`` () =
        //     let jsonNull = JsonNull
        //     Assert.IsType<JsonNull>(jsonNull)