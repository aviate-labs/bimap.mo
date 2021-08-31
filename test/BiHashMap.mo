import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

import BiHashMap "../src/BiHashMap";

do {
    let m = BiHashMap.BiHashMap<Nat, Text>(
        0, 
        Nat.equal, Hash.hash,
        Text.equal, Text.hash,
    );

    assert(m.replace(0, "a") == #Neither);
    assert(m.replace(0, "b") == #Left(0, "a"));
    assert(m.replace(1, "b") == #Right(0, "b"));
    assert(m.replace(1, "b") == #Pair(1, "b"));

    assert(m.replace(2, "c") == #Neither);
    assert(m.replace(1, "c") == #Both((1, "b"), (2, "c")));
};

do {
    let m = BiHashMap.BiHashMap<Nat, Text>(
        0, 
        Nat.equal, Hash.hash,
        Text.equal, Text.hash,
    );

    assert(m.insert(0, "a") == #ok());
    assert(m.insert(0, "b") == #err((0, "b")));
    assert(m.insert(1, "a") == #err((1, "a")));
};

do {
    let m = BiHashMap.BiHashMap<Nat, Text>(
        0, 
        Nat.equal, Hash.hash,
        Text.equal, Text.hash,
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
