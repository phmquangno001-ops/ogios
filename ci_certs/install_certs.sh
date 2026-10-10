#!/usr/bin/env bash
# Script tự động giải mã và cài đặt chứng chỉ iOS với mật khẩu: 1
set -e
echo "Configuring iOS Keychain with imported certificate..."
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp ci_certs/cert.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/ || true

KEYCHAIN_PATH=$RUNNER_TEMP/build.keychain
security create-keychain -p "buildpass" $KEYCHAIN_PATH
security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
security unlock-keychain -p "buildpass" $KEYCHAIN_PATH

if [ -f "ci_certs/cert.p12" ]; then
  security import "ci_certs/cert.p12" -P "1" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH || true
  security set-key-partition-list -S apple-tool:,apple: -s -k "buildpass" $KEYCHAIN_PATH || true
  security list-keychain -d user -s $KEYCHAIN_PATH
fi
echo "Certificate setup complete."
