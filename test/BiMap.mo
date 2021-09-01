import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

import BiMap "../src/BiMap";
import BiHashMap "../src/BiHashMap";
import BiTrieMap "../src/BiTrieMap";

for (empty in [
    (
        BiHashMap.empty<Nat,  Text>(0, Nat.equal, Hash.hash),
        BiHashMap.empty<Text, Nat>(0, Text.equal, Text.hash),
    ),
    //(
    //    BiTrieMap.empty<Nat,  Text>(Nat.equal, Hash.hash),
    //    BiTrieMap.empty<Text, Nat>(Text.equal, Text.hash),
    //),
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
        m.retain(func (l : Nat, r : Text) : Bool {
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
