#!/bin/bash

# Конфигурация
PING_TARGET="10.8.0.1"
RETRY_LIMIT=5
RETRY_DELAY=10
RESTART_COMMAND="sudo reboot"

# Переменные
retry_count=0

# Первоначальная проверка сети перед началом цикла
echo "Проверка начального состояния сети..."
if ping -c 1 -W 2 $PING_TARGET > /dev/null; then
  echo "Сеть доступна. Начинаем мониторинг."
else
  echo "Сеть недоступна при первом запуске. Ждем $RETRY_DELAY секунд перед первой попыткой."
  sleep $RETRY_DELAY
fi

# Основной цикл
while true; do
  # Проверяем наличие сети
  if ping -c 1 -W 2 $PING_TARGET > /dev/null; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") Сеть доступна."
    retry_count=0
    break
  else
    echo "$(date +"%Y-%m-%d %H:%M:%S") Сеть недоступна. Попытка $retry_count из $RETRY_LIMIT."
    ((retry_count++))

    # Проверяем, достиг ли счетчик лимита
    if ((retry_count >= RETRY_LIMIT)); then
      echo "$(date +"%Y-%m-%d %H:%M:%S") Превышено количество попыток восстановления сети. Перезапускаем устройство..."
      $RESTART_COMMAND
    else
      echo "$(date +"%Y-%m-%d %H:%M:%S") Ждем $RETRY_DELAY секунд перед следующей попыткой."
      sleep $RETRY_DELAY
    fi
  fi
done
