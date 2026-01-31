.PHONY: publish

publish:
	@# Проверяем наличие книги в publish/
	@if [ -z "$$(ls -A publish/ 2>/dev/null)" ]; then \
		echo "Ошибка: папка publish/ пуста. Добавьте книгу (epub, pdf, fb2)."; \
		exit 1; \
	fi
	@echo "Публикация сайта..."
	git add -A
	git commit -m "Publish book" || echo "Нет изменений для коммита"
	git push origin main
	@# Включаем GitHub Pages если ещё не включен
	gh repo edit --enable-wiki=false 2>/dev/null || true
	gh api -X PUT /repos/{owner}/{repo}/pages \
		-f source.branch=main \
		-f source.path=/ 2>/dev/null || \
	gh api -X POST /repos/{owner}/{repo}/pages \
		-f source.branch=main \
		-f source.path=/ 2>/dev/null || true
	@echo "Готово! Сайт будет доступен через 1-2 минуты по адресу:"
	@gh repo view --json url -q '.url' | sed 's|github.com|github.io|; s|.com/|.io/|'
