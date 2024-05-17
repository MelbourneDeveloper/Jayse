namespace Jayse

module JsonValue =

    open System

    type JsonValue =
        | JsonString of string
        | JsonNumber of float
        | JsonBoolean of bool
        | JsonArray of JsonValue list
        | JsonObject of Map<string, JsonValue>
        | JsonNull
        | Undefined
        | WrongType of obj

        static member FromJson(json: obj) =
            match json with
            | :? string as str -> JsonString str
            | :? float as num -> JsonNumber num
            | :? int as num -> JsonNumber (float num)
            | :? int64 as num -> JsonNumber (float num)
            | :? bool as boolean -> JsonBoolean boolean
            | :? (JsonValue list) as list -> JsonArray list
            | :? Map<string, JsonValue> as map -> JsonObject map
            | _ -> raise (ArgumentException($"Unknown JSON value type: {json.GetType()}"))

        member this.IsSome =
            match this with
            | JsonString _ | JsonNumber _ | JsonBoolean _ | JsonArray _ | JsonObject _ -> true
            | JsonNull | Undefined | WrongType _ -> false

        member this.IsNone = not this.IsSome

        override this.ToString() =
            match this with
            | JsonString value -> $"'{value}'"
            | JsonNumber value -> value.ToString()
            | JsonBoolean value -> value.ToString()
            | JsonArray value -> String.Join(", ", value |> List.map (fun e -> e.ToString()))
            | JsonObject value -> value.ToString()
            | JsonNull -> "JsonNull"
            | Undefined -> "Undefined"
            | WrongType value -> $"WrongType({value})"

        static member op_GetIndex(this: JsonValue, field: string) =
            match this with
            | JsonObject jo when jo.ContainsKey field -> jo.[field]
            | _ -> Undefined

        member this.StringValue =
            match this with
            | JsonString value -> Some value
            | _ -> None

        member this.NumericValue =
            match this with
            | JsonNumber value -> Some value
            | _ -> None

        member this.ObjectValue =
            match this with
            | JsonObject value -> Some value
            | _ -> None

        member this.BooleanValue =
            match this with
            | JsonBoolean value -> Some value
            | _ -> None

        member this.IntegerValue =
            match this with
            | JsonNumber value when value % 1.0 = 0.0 -> Some (int value)
            | _ -> None

        member this.DoubleValue =
            match this with
            | JsonNumber value -> Some value
            | _ -> None

        member this.DateTimeValue =
            match this with
            | JsonString value -> DateTime.TryParse value |> function true, dt -> Some dt | _ -> None
            | _ -> None

        member this.GetValue(field: string) =
            match this with
            | JsonObject jo -> jo.[field]
            | _ -> Undefined

        member this.ArrayValue =
            match this with
            | JsonArray value -> Some value
            | _ -> None

        member this.ToJson() =
            match this with
            | JsonString jsonString -> jsonString :> obj
            | JsonNumber jsonNumber -> jsonNumber :> obj
            | JsonBoolean jsonBoolean -> jsonBoolean :> obj
            | JsonArray jsonArray -> jsonArray |> List.map (fun v -> v.ToJson()) :> obj
            | JsonObject jsonObject -> jsonObject.Value |> Map.map (fun _ v -> v.ToJson()) :> obj
            | JsonNull -> null
            | Undefined -> null
            | WrongType wrongType -> wrongType

    and JsonObject(value: Map<string, JsonValue>) =
        member _.Value = value

        member this.WithUpdates(updates: Map<string, JsonValue>) =
            let mutable jo = this
            for KeyValue(key, value) in updates do
                jo <- jo.WithUpdate(key, value)
            jo

        member this.WithUpdate(key: string, value: JsonValue) =
            let entries = Map.toList this.Value
            let mutable replaced = false
            let mutable newEntries = []
            for (k, v) in entries do
                if k = key then
                    newEntries <- (key, value) :: newEntries
                    replaced <- true
                else
                    newEntries <- (k, v) :: newEntries

            if not replaced then
                newEntries <- (key, value) :: newEntries

            JsonObject(Map.ofList newEntries)

        member this.TryGetValue<'T>(field: string) =
            match value.TryFind field with
            | Some (JsonString jsonString) when typeof<'T> = typeof<string> -> Some (jsonString :> obj :?> 'T)
            | Some (JsonNumber jsonNumber) when typeof<'T> = typeof<float> || (typeof<'T> = typeof<int> && jsonNumber % 1.0 = 0.0) -> Some (jsonNumber :> obj :?> 'T)
            | Some (JsonBoolean jsonBoolean) when typeof<'T> = typeof<bool> -> Some (jsonBoolean :> obj :?> 'T)
            | Some (JsonArray jsonArray) when typeof<'T> = typeof<JsonValue list> -> Some (jsonArray :> obj :?> 'T)
            | Some (JsonObject jsonObject) when typeof<'T> = typeof<JsonObject> -> Some (jsonObject :> obj :?> 'T)
            | None -> None
            | _ -> None

        member this.Fields = Map.keys value

        member this.ContainsKey(key: string) = value.ContainsKey key

        override this.ToString() =
            let entries = value |> Map.toList |> List.map (fun (k, v) -> $"{k}: {v}")
            "{" + (String.Join(", ", entries)) + "}"

    and JsonArray(value: JsonValue list) =
        member _.Value = value

        static member Unmodifiable(values: JsonValue seq) =
            JsonArray(List.ofSeq values)

        member this.Item
            with get(index) =
                if index < List.length value then value.[index] else Undefined

        member this.First =
            if not (List.isEmpty value) then List.head value else Undefined

        member this.Length = List.length value

    let JsonValueEncode (value: JsonObject) =
        System.Text.Json.JsonSerializer.Serialize(value.Value |> Map.map (fun _ v -> v.ToJson()))

    let JsonValueDecode (value: string) =
        JsonValue.FromJson (System.Text.Json.JsonSerializer.Deserialize<obj>(value))

module JsonValueExtensions =
    let inline toJsonValue (value: ^T) =
        (^T : (static member ToJsonValue: ^T -> JsonValue.JsonValue) value)
