# Norse LoRA

Train a LoRA adapter for Old Norse text generation on Apple Silicon.

## What this project trains

This project fine-tunes [Sao10K/Fimbulvetr-11B-v2](https://huggingface.co/Sao10K/Fimbulvetr-11B-v2).
It uses LoRA (Low-Rank Adaptation) through the `mlx_lm` package.
LoRA holds the base model weights fixed.
LoRA trains a small set of adapter matrices instead.
This method needs much less memory than a full fine-tune.

The configuration applies LoRA to 16 layers at rank 8.
Training runs for 1000 iterations at a batch size of 1.
Edit `lora_config.yaml` to change these values.

The target task is Old Norse translation and question answering.
The model reads an instruction in English.
The model writes a response in Old Norse.

## Training data

The `data/` directory holds four example records.
Three records are English to Old Norse translation pairs.
One record answers a question about Yggdrasil in Old Norse prose.
That answer follows Gylfaginning in the Prose Edda.
The Prose Edda dates from about 1220 and is in the public domain.

These four records show the file format only.
They are too few to train a useful adapter.
Build a larger corpus before you start a real training run.

## Requirements

- You need a Mac with Apple Silicon.
- You need Python 3.9 or later.
- You need `mlx-lm` version 0.30 or later. Install it with `pip install mlx-lm`.
- You need the base model in MLX format.
- The 4-bit model uses about 6 GB. Use 16 GB of unified memory or more.

## Prepare the base model

Convert the base model to MLX format and quantize it to 4 bits.

```bash
python3 -m mlx_lm.convert \
  --hf-path Sao10K/Fimbulvetr-11B-v2 \
  --mlx-path ./model \
  -q
```

The scripts read the model path from the `MODEL` variable.
The default value is `./model`.
Set `MODEL` to another value if you store the model in a different place.

## Prepare the data

Write your training records to `data/train.jsonl`.
Write your validation records to `data/valid.jsonl`.
Use about 10 percent of your records for validation.

Each line is one JSON object with a single `text` field.
Use the instruction format for prompt and response pairs.

```json
{"text": "<s>[INST] Translate to Old Norse: The wolf runs. [/INST] Úlfrinn rennr.</s>"}
```

Use plain text for continuation training.

```json
{"text": "Hér segir frá Sigurði Fáfnisbana ..."}
```

Check the licence of each source text before you add it.
Medieval Norse texts are in the public domain.
Modern translations and modern critical editions are often still in copyright.

## Train

Start the training run.

```bash
./train.sh
```

Set the model path first if you use a different location.

```bash
MODEL=../shared/model ./train.sh
```

The script writes the adapter to `adapters/`.
The script saves a checkpoint every 200 iterations.
The script reports the loss every 10 iterations.
It runs a validation pass every 100 iterations.

## Generate text with the adapter

```bash
python3 -m mlx_lm.generate \
  --model ./model \
  --adapter-path ./adapters \
  --prompt "Translate to Old Norse: The raven flies over the mountain."
```

## Licence

Licensed under the PolyForm Noncommercial License 1.0.0. Copyright 2026 Seraphine Renard.

The licence covers the code and the configuration in this repository.
Third-party data keeps its own terms.
The base model keeps the terms of its own licence.
