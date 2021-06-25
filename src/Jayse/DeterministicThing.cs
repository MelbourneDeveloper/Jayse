using System.Collections;
using System.Collections.Generic;
using System.Collections.Immutable;

#pragma warning disable IDE1006 // Naming Styles
#pragma warning disable CA1304 // Specify CultureInfo
#pragma warning disable CA1305 // Specify IFormatProvider

namespace Jayse
{
    public class DeterministicThing<TKey, TValue> : IEnumerable<KeyValuePair<TKey, TValue>>
        where TKey : notnull
    {
        private readonly ImmutableList<KeyValuePair<TKey, TValue>> kvpList;
        private readonly ImmutableDictionary<TKey, TValue> kvpDictionary;

        public DeterministicThing(IEnumerable<KeyValuePair<TKey, TValue>> kvps)
        {
            kvpList = kvps.ToImmutableList();
            kvpDictionary = kvps.ToImmutableDictionary(pair => pair.Key, pair => pair.Value);
        }

        public IEnumerator<KeyValuePair<TKey, TValue>> GetEnumerator() => kvpList.GetEnumerator();
        IEnumerator IEnumerable.GetEnumerator() => kvpList.GetEnumerator();
        public TValue this[TKey key] => kvpDictionary[key];
    }
}
