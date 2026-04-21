while true; do
    sleep 15
    if [ -n "$(git status --porcelain)" ]; then
        git add -A
        git commit -m "Auto commit"
        git push origin HEAD
    fi
done