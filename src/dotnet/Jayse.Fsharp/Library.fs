module JsonValue

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
        | JsonObject value -> JsonValueEncode value
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

and JsonObject(value: Map<string, JsonValue>) =
    member _.Value = value

    member this.WithUpdates(updates: Map<string, JsonValue>) =
        let mutable jo = this
        for KeyValue(key, value) in updates do
            jo <- jo.WithUpdate(key, value)
        jo

    member this.WithUpdate(key: string, value: JsonValue) =
        let entries = value |> Map.toList
        let mutable replaced = false
        let mutable i = entries.Length - 1
        while i >= 0 do
            let key', value' = entries.[i]
            if key' = key then
                entries.RemoveAt(i)
                entries.Insert(i, (key, value))
                replaced <- true
                i <- -1
            else
                i <- i - 1

        if not replaced then
            entries.Add((key, value))

        JsonObject(entries |> Map.ofList)

    member this.Value<'T>(field: string) =
        match value.TryFind field with
        | Some (JsonString jsonString) when typeof<'T> = typeof<string> -> Some (jsonString :?> 'T)
        | Some (JsonNumber jsonNumber) when typeof<'T> = typeof<float> || typeof<'T> = typeof<int> && jsonNumber % 1.0 = 0.0 || typeof<'T> = typeof<float> -> Some (jsonNumber :?> 'T)
        | Some (JsonBoolean jsonBoolean) when typeof<'T> = typeof<bool> -> Some (jsonBoolean :?> 'T)
        | Some (JsonArray jsonArray) when typeof<'T> = typeof<JsonArray> -> Some (jsonArray :?> 'T)
        | Some (JsonArray jsonArray) when typeof<'T> = typeof<JsonValue list> -> Some (jsonArray.Value :?> 'T)
        | Some (JsonObject jsonObject) when typeof<'T> = typeof<JsonObject> -> Some (jsonObject :?> 'T)
        | None -> None
        | _ -> None

    member this.Fields = value |> Map.keys

    member this.ToJson() =
        value
        |> Map.map (fun _ jsonValue -> jsonValueToJson jsonValue)

    member this.ContainsKey(key: string) = value.ContainsKey key

and JsonArray(value: JsonValue list) =
    member _.Value = value

    static member Unmodifiable(values: JsonValue seq) =
        JsonArray(values |> List.ofSeq)

    member this.Item
        with get(index) =
            if index < value.Length then value.[index] else Undefined

    member this.First =
        if not value.IsEmpty then value.Head else Undefined

    member this.Length = value.Length

let rec jsonValueToJson (jsonValue: JsonValue) =
    match jsonValue with
    | JsonString jsonString -> jsonString :> obj
    | JsonNumber jsonNumber -> jsonNumber :> obj
    | JsonBoolean jsonBoolean -> jsonBoolean :> obj
    | JsonArray jsonArray -> jsonArray.Value |> List.map jsonValueToJson :> obj
    | JsonObject jsonObject -> jsonObject.ToJson() :> obj
    | JsonNull -> null
    | Undefined -> null
    | WrongType wrongType -> wrongType :> obj

let JsonValueEncode (value: JsonObject) =
    System.Text.Json.JsonSerializer.Serialize(value.ToJson())

let JsonValueDecode (value: string) =
    JsonValue.FromJson (System.Text.Json.JsonSerializer.Deserialize<obj>(value))

module JsonValueExtensions =
    let inline toJsonValue (value: ^T) =
        (^T : (static member ToJsonValue: ^T -> JsonValue) value)

module StringExtensions =
    type System.Nullable<string> with
        member this.ToJsonValue() =
            match this with
            | null -> JsonNull
            | value -> JsonString value

module MapExtensions =
    type Map<string, obj> with
        member this.ToJsonValue() =
            this
            |> Map.map (fun _ value -> JsonValue.FromJson value)
            |> JsonObject