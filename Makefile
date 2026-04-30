.PHONY: api-docker api-local app gen build-apk install clean help

# Default command
help:
	@echo "Available commands:"
	@echo "  make api-docker  - Start backend via Docker Compose"
	@echo "  make api-local   - Start backend locally with Poetry"
	@echo "  make app         - Run the Flutter app"
	@echo "  make gen         - Run Flutter code generation (build_runner)"
	@echo "  make build-apk   - Build release APK"
	@echo "  make install     - Install dependencies for both API and App"
	@echo "  make clean       - Clean Flutter build artifacts"

# --- Backend (API) ---
api-docker:
	docker compose up api

api-local:
	cd api && poetry run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# --- Frontend (Flutter) ---
app:
	cd velo_app && flutter run

gen:
	cd velo_app && dart run build_runner build --delete-conflicting-outputs

build-apk:
	cd velo_app && flutter build apk --release

# --- Utilities ---
install:
	cd api && poetry install
	cd velo_app && flutter pub get

clean:
	cd velo_app && flutter clean
