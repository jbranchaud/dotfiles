#!/usr/bin/env bun
// @ts-nocheck

export {};

const EM_DASH = '\u2014';
const ASCII_DASH = '-';

const normalize = (text: string): string => text.split(EM_DASH).join(ASCII_DASH);

const args = process.argv.slice(2);
const inPlace = args.includes('--in-place');
const positionalArgs = args.filter((arg) => arg !== '--in-place');
const filePath = positionalArgs[0];

if (positionalArgs.length > 1) {
  console.error('Usage: replace_mdashes.ts [--in-place] [file]');
  process.exit(1);
}

if (inPlace && !filePath) {
  console.error('--in-place requires an input file');
  process.exit(1);
}

if (filePath) {
  const inputText = await Bun.file(filePath).text();
  const outputText = normalize(inputText);

  if (inPlace) {
    await Bun.write(filePath, outputText);
  } else {
    process.stdout.write(outputText);
  }

  process.exit(0);
}

const inputText = await new Response(Bun.stdin.stream()).text();
const outputText = normalize(inputText);
process.stdout.write(outputText);
