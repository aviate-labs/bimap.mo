import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

import BiMap "../src/BiMap";
import BiHashMap "../src/BiHashMap";
import BiTrieMap "../src/BiTrieMap";

let h = func (n : Nat32) : Nat32 { n };
let e = func (x : Nat32, y : Nat32) : Bool { x == y };

for (empty in [
    (
        BiHashMap.empty<Nat32, Text>(0, e, h),
        BiHashMap.empty<Text, Nat32>(0, Text.equal, Text.hash),
    ),
    (
        BiTrieMap.empty<Nat32, Text>(e, h),
        BiTrieMap.empty<Text, Nat32>(Text.equal, Text.hash),
    ),
].vals()) {
    do {
        let m = BiMap.New(
            empty.0,
            empty.1,
            Text.equal,
        );

        assert(m.replace(0, "a") == #Neither);
        assert(m.replace(0, "b") == #Left(0, "a"));
        assert(m.replace(1, "b") == #Right(0, "b"));
        assert(m.replace(1, "b") == #Pair(1, "b"));

        assert(m.replace(2, "c") == #Neither);
        assert(m.replace(1, "c") == #Both((1, "b"), (2, "c")));
    };

    do {
        let m = BiMap.New(
            empty.0,
            empty.1,
            Text.equal,
        );

        assert(m.insert(0, "a") == #ok());
        assert(m.insert(0, "b") == #err((0, "b")));
        assert(m.insert(1, "a") == #err((1, "a")));
    };

    do {
        let m = BiMap.New(
            empty.0,
            empty.1,
            Text.equal,
        );

        ignore m.insert(0, "a");
        ignore m.insert(1, "b");
        ignore m.insert(2, "c");
        var i = 0;
        m.retain(func (l : Nat32, r : Text) : Bool {
            i += 1;
            i <= 1; // Only keep first.
        });
        assert(m.size() == 1);
        assert(m.getByLeft(0) == ?"a");
        assert(i == 3);
    };

    do {
        let m = BiMap.New(
            empty.0,
            empty.1,
            Text.equal,
        );

        ignore m.insert(0, "a");
        ignore m.insert(1, "b");
        ignore m.insert(2, "c");
        
        let c = BiMap.copy(m, empty.0, empty.1, Text.equal);
        assert(Iter.toArray(m.entries()) == Iter.toArray(c.entries()));

        let i = BiMap.fromIter(m.entries(), empty.0, empty.1, Text.equal);
        assert(Iter.toArray(m.entries()) == Iter.toArray(i.entries()))
    };
};
