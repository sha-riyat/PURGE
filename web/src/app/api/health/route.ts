import { NextResponse } from "next/server";

export function GET() {
  return NextResponse.json({ name: "PURGE", status: "ready", flow: "windows-native-reset", version: "0.1.0" });
}
