while true; do
    sleep 15
    if [ -n "$(git status --porcelain)" ]; then
        git add --all
        git commit -m "Auto commit"
        git push origin HEAD
    fi
done