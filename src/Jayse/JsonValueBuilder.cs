using System.Collections.Generic;

namespace Jayse
{
    public class JsonValueBuilder
    {
        private readonly List<KeyValuePair<string, JsonValue>> pairs = new();

        public JsonValueBuilder Add(string key, JsonValue value)
        {
            pairs.Add(new(key, value));
            return this;
        }

        public OrderedImmutableDictionary<string, JsonValue> Build()
            => new(pairs);
    }
}
