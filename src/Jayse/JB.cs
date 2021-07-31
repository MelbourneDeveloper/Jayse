using System;
using System.Collections.Generic;


#pragma warning disable IDE1006 // Naming Styles
#pragma warning disable CS8603 // Possible null reference return.


namespace Jayse
{

    public record JB
    {
        #region Fields
        private string? stringValue { get; init; }
        private bool? booleanValue { get; init; }
        private decimal? numberValue { get; init; }
        private Dictionary<string, JsonValue> objectValue { get; } = new Dictionary<string, JsonValue>();
        private List<JsonValue> arrayValue { get; } = new List<JsonValue>();
        #endregion

        #region Public Properties
        public string StringValue { get => stringValue ?? throw new InvalidOperationException(); init { stringValue = value; } }
        public bool BooleanValue { get => booleanValue ?? throw new InvalidOperationException(); init { booleanValue = value; } }
        public decimal NumberValue { get => numberValue ?? throw new InvalidOperationException(); init { numberValue = value; } }
        public IDictionary<string, JsonValue> ObjectValue => objectValue;
        public IList<JsonValue> ArrayValue => arrayValue;
        public JsonValue this[string key] => ObjectValue[key];
        public JsonValue this[int index] => ArrayValue[index];
        public JsonValueType ValueType =>
            stringValue != null ? JsonValueType.OfString :
            booleanValue.HasValue ? JsonValueType.OfBoolean :
            numberValue.HasValue ? JsonValueType.OfNumber :
            arrayValue != null ? JsonValueType.OfArray :
            objectValue != null ? JsonValueType.OfObject :
            JsonValueType.OfNull;
        #endregion

        #region Constructors
        public JB() { }
        public JB(string value) => stringValue = value;
        public JB(bool value) => booleanValue = value;
        public JB(decimal value) => numberValue = value;
        public JB(Dictionary<string, JsonValue> value) => objectValue = value;
        public JB(IEnumerable<JsonValue> value)
        {
            arrayValue = new List<JsonValue>();
            arrayValue.AddRange(value);
        }
        #endregion

    }

    public static class Adasds
    {
        public static JB FromAdasd(this OrderedImmutableDictionary<string, JsonValue> jsonObject)
        {
            var jb = new Dictionary<string, JB>();

            if (jsonObject == null) throw new ArgumentNullException(nameof(jsonObject));
            foreach (var kvp in jsonObject)
            {
                switch (kvp.Value.ValueType)
                {
                    case JsonValueType.OfString:
                        jb.Add(kvp.Key, new JB(kvp.Value.StringValue));
                        break;
                    case JsonValueType.OfObject:
                        jb.Add(kvp.Key, FromAdasd(kvp.Value.ObjectValue));
                        break;

                }

            }
        }
    }

}
