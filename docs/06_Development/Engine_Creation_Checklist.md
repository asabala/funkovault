# Atlas Engine Creation Checklist

Every new engine should answer these questions before implementation.

---

## Responsibility

What single problem does this engine solve?

Can the responsibility be explained in one sentence?

---

## Inputs

What information does the engine require?

Where does the data come from?

---

## Outputs

What result does the engine produce?

Is the output reusable?

---

## Dependencies

Does the engine depend on UI?

If yes, redesign it.

Does the engine duplicate another engine?

If yes, redesign it.

---

## Reuse

Will another feature likely use this engine?

If not...

Should it actually be a service?

---

## Documentation

ADR created?

Feature document created?

Implementation notes required?

---

## Testing

Expected inputs documented?

Edge cases considered?

Legacy data supported?

---

## Long-Term Vision

Will this engine still make sense in five years?

Can future collectible categories reuse it?

Can AI consume its results?

If yes...

Build it.