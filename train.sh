#!/usr/bin/env bash
set -euo pipefail

MODEL="${MODEL:-./model}"
DATA="./data"
CONFIG="./lora_config.yaml"
ADAPTER="./adapters"

# Verify model exists
if [ ! -d "$MODEL" ]; then
  echo "ERROR: $MODEL not found. Convert the base model to MLX format first."
  echo "Set MODEL to override the default path. See README.md."
  exit 1
fi

# Verify data exists
if [ ! -f "$DATA/train.jsonl" ]; then
  echo "ERROR: $DATA/train.jsonl not found. Prepare your training data first."
  echo "See README.md for format details."
  exit 1
fi

mkdir -p "$ADAPTER"

echo "Starting LoRA training..."
echo "Model:   $MODEL"
echo "Data:    $DATA"
echo "Config:  $CONFIG"
echo "Output:  $ADAPTER"
echo ""

python3 -m mlx_lm.lora \
  --model "$MODEL" \
  --data "$DATA" \
  --train \
  --config "$CONFIG" \
  --adapter-path "$ADAPTER"

echo ""
echo "Training complete! Adapter saved to $ADAPTER"
echo "Test with:"
echo "  python3 -m mlx_lm.generate --model $MODEL --adapter-path $ADAPTER --prompt 'Your prompt here'"
