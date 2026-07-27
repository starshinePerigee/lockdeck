extends Resource
## LockSpec is a dataclass that entirely defines a lock.
class_name LockSpec

## Holds all the templates that went into creating this lock
var templates: Array[DepthTemplates]

## Holds the actual PinSpecs
var pins: Array[PinSpec]