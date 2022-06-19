#!/usr/bin/zsh

# This script helps in creating a backup of one disk to the other

# ===== Step 1: Show the disks ======
lsblk

# ===== Step 2: Select the input source disk =====
echo "Select the Input Disk:"
read input_disk

echo "Input Disk is: /dev/${input_disk}"

echo "Are you sure? [Y/n]"
read input_answer
if [ "$input_answer" != "${input_answer#[Yy]}" ]; then
  echo "Selecting ${input_disk} as the Input Disk"
else
  exit 0
fi

# ===== Step 3: Select the output source disk =====
echo "Select the output disk:"
read output_disk

echo "Output Disk is: ${output_disk}"

echo "Are you sure? [Y/n]"
read output_answer
if [ "$output_answer" != "${output_answer#[Yy]}" ]; then
  echo "Selecting ${output_disk} as the Output Disk"
else
  exit 0
fi


# ==== Step 4: Do work =====
echo "The command: sudo dd if=/dev/${input_disk} of=/dev/${output_disk} bs=64M status=progress"

echo "Are you sure you want to do this operation? [Y/n]"
read final_confirmation
if [ "$final_confirmation" != "${final_confirmation#[Yy]}" ]; then
  sudo dd if=/dev/${input_disk} of=/dev/${output_disk} bs=64M status=progress
else
  exit 0
fi


