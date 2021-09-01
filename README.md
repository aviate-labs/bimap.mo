# BiMap

A Motoko module for bijective maps.

A bimap (or "bidirectional map") is a map that preserves the uniqueness of its values as well as that of its keys.

🛑 Do not use `mo:base/TrieMap`, there is a bug in which results in an `arithmetic overflow`.

## Usage

```motoko
let m = BiMap.New(
    BiHashMap.empty<Nat,  Text>(0, Nat.equal, Hash.hash),
    BiHashMap.empty<Text, Nat>(0, Text.equal, Text.hash),
    Text.equal,
);

m.insert(0, "a");

m.getByLeft(0);
// [(0, "a")];
m.getByRight("a");
// [(0, "a")];
```

Works with any `object` that implements the following interface:

```motoko
type Map<L, R> = {
    // Returns the number of entries in this map.
    size() : Nat;
    // Returns an iterator over the key value pairs in this map.
    entries() : Iter.Iter<(L, R)>;
    // Gets the entry with the key `k` and returns its associated value if it existed or `null` otherwise.
    get(k : L) : ?R;
    // Removes the entry with the key `k` and returns the associated value if it existed or `null` otherwise.
    remove(k : L) : ?R;
    // Insert the value `v` at key `k`. Overwrites an existing entry with key `k`.
    put(k : L, v : R) : ();
};
```

## Predefined Empty Map Generators

- TrieMap
- HashMap
