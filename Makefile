.PHONY: publish

publish:
	@# Проверяем наличие книги в publish/
	@if [ -z "$$(ls publish/*.epub publish/*.pdf publish/*.fb2 2>/dev/null)" ]; then \
		echo "Ошибка: папка publish/ пуста. Добавьте книгу (epub, pdf, fb2)."; \
		exit 1; \
	fi
	@# Генерируем список файлов
	@ls -1 publish/*.epub publish/*.pdf publish/*.fb2 2>/dev/null | xargs -n1 basename | jq -R -s 'split("\n") | map(select(length > 0))' > publish/files.json
	@echo "Публикация сайта..."
	git add -A
	git commit -m "Publish book" || echo "Нет изменений для коммита"
	git push origin main
	@# Включаем GitHub Pages если ещё не включён
	@gh api repos/:owner/:repo/pages --silent 2>/dev/null || \
		gh api -X POST repos/:owner/:repo/pages -f "build_type=legacy" -f "source[branch]=main" -f "source[path]=/" --silent 2>/dev/null || true
	@echo "Готово! Сайт будет доступен через 1-2 минуты по адресу:"
	@gh api repos/:owner/:repo/pages --jq '.html_url' 2>/dev/null || echo "https://$$(gh api repos/:owner/:repo --jq '.owner.login').github.io/$$(gh api repos/:owner/:repo --jq '.name')/"
