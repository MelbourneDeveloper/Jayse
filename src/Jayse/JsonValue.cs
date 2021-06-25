using System;
using System.Collections.Immutable;
using System.Linq;

#pragma warning disable IDE1006 // Naming Styles
#pragma warning disable CA1304 // Specify CultureInfo
#pragma warning disable CA1305 // Specify IFormatProvider

namespace Jayse
{

    public record JsonValue
    {
        #region Fields
        private string? stringValue { get; init; }
        private bool? booleanValue { get; init; }
        private decimal? numberValue { get; init; }
        private ImmutableDictionary<string, JsonValue>? objectValue { get; init; }
        private ImmutableList<JsonValue>? arrayValue { get; init; }
        #endregion

        #region Public Properties
        public string StringValue { get => stringValue ?? throw new InvalidOperationException(); init { stringValue = value; } }
        public bool BooleanValue { get => booleanValue ?? throw new InvalidOperationException(); init { booleanValue = value; } }
        public decimal NumberValue { get => numberValue ?? throw new InvalidOperationException(); init { numberValue = value; } }
        public ImmutableDictionary<string, JsonValue> ObjectValue { get => objectValue ?? throw new InvalidOperationException(); init { objectValue = value; } }
        public ImmutableList<JsonValue> ArrayValue { get => arrayValue ?? throw new InvalidOperationException(); init { arrayValue = value; } }
        public JsonValue this[string key] => ObjectValue[key];
        public JsonValue this[int index] => ArrayValue[index];
        public JsonValueType ValueType { get; }
        #endregion

        #region Constructors
        public JsonValue() => ValueType = JsonValueType.OfNull;
        public JsonValue(string value) { stringValue = value; ValueType = JsonValueType.OfString; }
        public JsonValue(bool value) { booleanValue = value; ValueType = JsonValueType.OfBoolean; }
        public JsonValue(decimal value) { numberValue = value; ValueType = JsonValueType.OfNumber; }
        public JsonValue(ImmutableDictionary<string, JsonValue> value) { objectValue = value; ValueType = JsonValueType.OfObject; }
        public JsonValue(ImmutableList<JsonValue> value) { arrayValue = value; ValueType = JsonValueType.OfArray; }
        #endregion

        #region Methods
        public string ToJson(bool format = false, int depth = 0)
        =>
            ValueType switch
            {
                JsonValueType.OfObject => (format ? "\r\n" : "") + ObjectValue.ToJson(format, depth + 1),
                JsonValueType.OfString => "\"" + StringValue + "\"",
                JsonValueType.OfArray => (format ? "\r\n" : "") + "\t".Repeat(depth) + "[" + string.Join($",", ArrayValue.Select(v => (format ? $"\r\n" : "") + "\t".Repeat(depth + 1) + v.ToJson(format, depth + 1))) + $"{(format ? "\r\n" : "")}{"\t".Repeat(depth)}]",
                JsonValueType.OfBoolean => BooleanValue.ToString().ToLower(),
                JsonValueType.OfNull => "null",
                JsonValueType.OfNumber => NumberValue.ToString(),
                _ => throw new NotImplementedException(),
            };
        #endregion
    }
}
