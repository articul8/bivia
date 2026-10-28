# Box the damage in a photo

Use `/ground` to point at an object in an image and get back a labelled bounding box: damage on a shipment, a missing safety rail, a part on a bench. This recipe finds the broken crate and the rusted part in a dock photo.

## Run

```bash
python3 run.py                        # the two built-in questions
python3 run.py "Find the forklift."   # your own question
./run.sh "Find the forklift."         # the same with curl + jq
```

## The request

```json
POST /ground
{
  "question": "Find the broken wooden crate.",
  "images": [{ "b64": "<data/dock_photo.jpg, base64>", "mime": "image/jpeg" }]
}
```

| Field | What to put in it |
|---|---|
| `question` | One object to find, described the way you'd describe it to a person ("Find the rusted gear housing.") |
| `images` | The image as `{ b64, mime }` |

## Reading the response

```json
{ "found": true, "value": [{ "label": "the broken wooden crate", "box": [285, 270, 755, 720] }] }
```

- `box` is `[x1, y1, x2, y2]`, the top-left and bottom-right corners.
- `found: false` means the object isn't in the image.
- Each call returns one box. To find two objects, make two calls.

## Adapting it

- Swap `data/dock_photo.jpg` for your own image and change the questions in the script.
- To decide something about the image (is there damage? which of these parts is it?), use `/boolean` or `/choice` with the image in `images[]`. Use `/ground` when you need to show *where*.
