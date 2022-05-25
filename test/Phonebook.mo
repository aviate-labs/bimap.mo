import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";

import BiMap "../src/BiMap";
import BiHashMap "../src/BiHashMap";

type Name  = Text;
type Phone = Text;

type Entry = {
    desc  : Text;
    phone : Phone;
};

func equalEntryPhone(a : Entry, b : Entry) : Bool {
    Text.equal(a.phone, b.phone);
};

func hashEntryPhone(e : Entry) : Hash.Hash {
    Text.hash(e.phone);
};

let m = BiMap.New(
    BiHashMap.empty<Name, Entry>(0, Text.equal, Text.hash),
    BiHashMap.empty<Entry, Name>(0, equalEntryPhone, hashEntryPhone),
    equalEntryPhone,
);

ignore m.insert("Bob", {
    desc  = "Home";
    phone = "555-1212";
});

assert(m.getByLeft("Bob") == ?{
    desc  = "Home";
    phone = "555-1212";
});

assert(m.getByRight({
    desc  = "";
    phone = "555-1212"
}) == ?"Bob");
