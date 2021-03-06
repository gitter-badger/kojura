﻿
#Область Константы

Перем кВидыСимволов;

Процедура Инициализировать()
	Перем Алфавит, Номер;
	кВидыСимволов = Новый Соответствие;
	Алфавит = (
		"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_=+-*/<>%!?" +
		"абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
	);
	Для Номер = 1 По СтрДлина(Алфавит) Цикл
		кВидыСимволов[Сред(Алфавит, Номер, 1)] = "Буква"
	КонецЦикла;
	Для Номер = 0 По 9 Цикл
		кВидыСимволов[Строка(Номер)] = "Цифра"
	КонецЦикла;
КонецПроцедуры // Инициализировать()

#КонецОбласти // Константы

#Область Парсер

Функция Парсер(Знач Исходник) Экспорт
	Возврат Новый Структура(
		"Исходник,"
		"Позиция,"
		"Символ,"
		"Окружение",
		Исходник, 1, Сред(Исходник, 1, 1)
	);
КонецФункции // Парсер()

Функция ПрочитатьСимвол(Знач Исходник, Позиция)
	Позиция = Позиция + 1;
	Возврат Сред(Исходник, Позиция, 1);
КонецФункции // ПрочитатьСимвол()

Процедура Следующий(Знач Парсер, Токен, Литерал)
	Перем Исходник, Позиция, Символ, Начало;
	Исходник = Парсер.Исходник;
	Позиция = Парсер.Позиция;
	Символ = Парсер.Символ;
	Пока ПустаяСтрока(Символ) И Символ <> "" Цикл
		Символ = ПрочитатьСимвол(Исходник, Позиция);
	КонецЦикла;
	Токен = кВидыСимволов[Символ];
	Если Токен = "Буква" Тогда
		Начало = Позиция;
		Символ = ПрочитатьСимвол(Исходник, Позиция);
		Пока кВидыСимволов[Символ] <> Неопределено Цикл
			Символ = ПрочитатьСимвол(Исходник, Позиция);
		КонецЦикла;
		Литерал = Сред(Парсер.Исходник, Начало, Позиция - Начало);
		Токен = "Объект";
	ИначеЕсли Токен = "Цифра" Тогда
		Начало = Позиция;
		Символ = ПрочитатьСимвол(Исходник, Позиция);
		Пока кВидыСимволов[Символ] = "Цифра" Цикл
			Символ = ПрочитатьСимвол(Исходник, Позиция);
		КонецЦикла;
		Если Символ = "." Тогда
			Символ = ПрочитатьСимвол(Исходник, Позиция);
			Пока кВидыСимволов[Символ] = "Цифра" Цикл
				Символ = ПрочитатьСимвол(Исходник, Позиция);
			КонецЦикла;
		КонецЕсли;
		Литерал = Сред(Парсер.Исходник, Начало, Позиция - Начало);
		Токен = "Число";
	ИначеЕсли Символ = """" Тогда
		Начало = Позиция + 1;
		Символ = ПрочитатьСимвол(Исходник, Позиция);
		Пока Символ <> """" И Символ <> "" Цикл
			Символ = ПрочитатьСимвол(Исходник, Позиция);
		КонецЦикла;
		Литерал = Сред(Парсер.Исходник, Начало, Позиция - Начало);
		Токен = "Строка";
		Символ = ПрочитатьСимвол(Исходник, Позиция);
	ИначеЕсли Символ = "(" Или Символ = ")" Или Символ = "" Тогда
		Токен = Символ;
		Символ = ПрочитатьСимвол(Исходник, Позиция);
	Иначе
		ВызватьИсключение СтрШаблон("Неизвестный символ %1", Символ);
	КонецЕсли;
	Парсер.Позиция = Позиция;
	Парсер.Символ = Символ;
КонецПроцедуры // Следующий()

Функция Список(Знач Тип, Знач Данные, Знач Следующий)
	Возврат Новый ФиксированнаяСтруктура("Тип, Данные, Следующий", Тип, Данные, Следующий);
КонецФункции // Список()

Функция Разобрать(Знач Парсер, Уровень = 0) Экспорт
	Перем Токен, Литерал;
	Следующий(Парсер, Токен, Литерал);
	Если Токен = "(" Тогда
		Уровень = Уровень + 1;
		Возврат Список("Список", Разобрать(Парсер, Уровень), Разобрать(Парсер, Уровень));
	ИначеЕсли Токен = ")" Тогда
		Если Уровень = 0 Тогда
			ВызватьИсключение "Неожиданный символ `)`";
		КонецЕсли;
		Уровень = Уровень - 1;
	ИначеЕсли Токен = "" Тогда
		Если Уровень > 0 Тогда
			ВызватьИсключение "Ожидается `)`";
		КонецЕсли;
	Иначе
		Возврат Список(Токен, Литерал, Разобрать(Парсер, Уровень))
	КонецЕсли;
	Возврат Неопределено;
КонецФункции // Разобрать()

#КонецОбласти // Парсер

#Область Окружение

Процедура ОткрытьОкружение(Окружение) Экспорт
	Окружение = Новый Структура("ВнешнееОкружение, Элементы", Окружение, Новый Соответствие);
КонецПроцедуры // ОткрытьОкружение()

Процедура ЗакрытьОкружение(Окружение) Экспорт
	Окружение = Окружение.ВнешнееОкружение;
КонецПроцедуры // ЗакрытьОкружение()

Функция ЭлементОкружения(Знач Окружение, Знач ИмяЭлемента) Экспорт
	Перем Элемент;
	Элемент = Окружение.Элементы[ИмяЭлемента];
	Пока Элемент = Неопределено И Окружение.ВнешнееОкружение <> Неопределено Цикл
		Окружение = Окружение.ВнешнееОкружение;
		Элемент = Окружение.Элементы[ИмяЭлемента];
	КонецЦикла;
	Если Элемент = Неопределено Тогда
		ВызватьИсключение СтрШаблон("Неизвестный атом %1", ИмяЭлемента);
	КонецЕсли;
	Возврат Элемент;
КонецФункции // ЭлементОкружения()

#КонецОбласти // Окружение

#Область Интерпретатор

Функция Сумма(Знач Окружение, Знач Аргумент)
	Перем Значение;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Следующий;
	Пока Аргумент <> Неопределено Цикл
		Значение = Значение + Интерпретировать(Окружение, Аргумент);
		Аргумент = Аргумент.Следующий;
	КонецЦикла;
	Возврат Значение;
КонецФункции // Сумма()

Функция Разность(Знач Окружение, Знач Аргумент)
	Перем Значение;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Следующий;
	Если Аргумент = Неопределено Тогда
		Возврат -Значение;
	КонецЕсли;
	Пока Аргумент <> Неопределено Цикл
		Значение = Значение - Интерпретировать(Окружение, Аргумент);
		Аргумент = Аргумент.Следующий;
	КонецЦикла;
	Возврат Значение;
КонецФункции // Разность()

Функция Произведение(Знач Окружение, Знач Аргумент)
	Перем Значение;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Следующий;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Пока Аргумент <> Неопределено Цикл
		Значение = Значение * Интерпретировать(Окружение, Аргумент);
		Аргумент = Аргумент.Следующий;
	КонецЦикла;
	Возврат Значение;
КонецФункции // Произведение()

Функция Частное(Знач Окружение, Знач Аргумент)
	Перем Значение;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Следующий;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Пока Аргумент <> Неопределено Цикл
		Значение = Значение / Интерпретировать(Окружение, Аргумент);
		Аргумент = Аргумент.Следующий;
	КонецЦикла;
	Возврат Значение;
КонецФункции // Частное()

Функция Остаток(Знач Окружение, Знач Аргумент)
	Перем Значение;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Следующий;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Пока Аргумент <> Неопределено Цикл
		Значение = Значение % Интерпретировать(Окружение, Аргумент);
		Аргумент = Аргумент.Следующий;
	КонецЦикла;
	Возврат Значение;
КонецФункции // Остаток()

Функция ЗначениеФункции(Знач Окружение, Знач СоставнаяФункция, Знач Аргумент)
	Перем Значение;
	ОткрытьОкружение(Окружение);
	Параметр = СоставнаяФункция.Данные;
	Пока Параметр <> Неопределено Цикл
		Если Аргумент = Неопределено Тогда
			ВызватьИсключение "Недостаточно фактических параметров";
		КонецЕсли;
		Окружение.Элементы[Параметр.Данные] = Интерпретировать(Окружение, Аргумент);
		Параметр = Параметр.Следующий;
		Аргумент = Аргумент.Следующий;
	КонецЦикла;
	Выражение = СоставнаяФункция.Следующий;
	Если Выражение = Неопределено Тогда
		ВызватьИсключение "Ожидается тело функции";
	КонецЕсли;
	Пока Выражение <> Неопределено Цикл
		Значение = Интерпретировать(Окружение, Выражение);
		Выражение = Выражение.Следующий;
	КонецЦикла;
	ЗакрытьОкружение(Окружение);
	Возврат Значение;
КонецФункции // ЗначениеФункции()

Функция ОпределениеФункции(Знач Окружение, Знач Список)
	Перем Имя, Параметры, Выражение;
	Имя = Список.Данные;
	Параметры = Список.Следующий;
	Выражение = Параметры.Следующий;
	Если Параметры.Тип = "Список" Тогда
		Параметры = Параметры.Данные;
		Если Не ПараметрыКорректны(Параметры) Тогда
			ВызватьИсключение "Ожидается имя параметра";
		КонецЕсли;
	ИначеЕсли Параметры.Тип <> "Объект" Тогда
		ВызватьИсключение "Ожидается имя параметра";
	Иначе
		Параметры = Список("Объект", Параметры.Данные, Неопределено);
	КонецЕсли;
	Окружение.Элементы[Имя] = Список("Функция", Параметры, Выражение);
	Возврат Неопределено;
КонецФункции // ОпределениеФункции()

// вспомогательная функция
Функция ПараметрыКорректны(Параметры)
	Возврат Параметры = Неопределено Или Параметры.Тип = "Объект" И ПараметрыКорректны(Параметры.Следующий);
КонецФункции // ПараметрыКорректны()

Функция ЗначениеВыраженияЕсли(Знач Окружение, Знач Список)
	Перем СписокЕсли, СписокТогда, СписокИначе;
	СписокЕсли = Список;
	СписокТогда = Список.Следующий;
	СписокИначе = Список.Следующий.Следующий;
	Возврат ?(
		Интерпретировать(Окружение, СписокЕсли),
			Интерпретировать(Окружение, СписокТогда),
			Интерпретировать(Окружение, СписокИначе)
	);
КонецФункции // ЗначениеВыраженияЕсли()

Функция Равно(Знач Окружение, Знач Аргумент)
	Перем Значение, Результат;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Следующий;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Результат = Истина;
	Пока Аргумент <> Неопределено И Результат Цикл
		Результат = Результат И Значение = Интерпретировать(Окружение, Аргумент);
		Аргумент = Аргумент.Следующий;
	КонецЦикла;
	Возврат Результат;
КонецФункции // Равно()

Функция Больше(Знач Окружение, Знач Аргумент)
	Перем Значение1, Значение2;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение1 = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Следующий;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Результат = Истина;
	Пока Аргумент <> Неопределено И Результат Цикл
		Значение2 = Интерпретировать(Окружение, Аргумент);
		Результат = Результат И Значение1 > Значение2;
		Значение1 = Значение2;
		Аргумент = Аргумент.Следующий;
	КонецЦикла;
	Возврат Результат;
КонецФункции // Больше()

Функция Меньше(Знач Окружение, Знач Аргумент)
	Перем Значение1, Значение2;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение1 = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Следующий;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Результат = Истина;
	Пока Аргумент <> Неопределено И Результат Цикл
		Значение2 = Интерпретировать(Окружение, Аргумент);
		Результат = Результат И Значение1 < Значение2;
		Значение1 = Значение2;
		Аргумент = Аргумент.Следующий;
	КонецЦикла;
	Возврат Результат;
КонецФункции // Меньше()

Функция БольшеИлиРавно(Знач Окружение, Знач Аргумент)
	Перем Значение1, Значение2;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение1 = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Следующий;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Результат = Истина;
	Пока Аргумент <> Неопределено И Результат Цикл
		Значение2 = Интерпретировать(Окружение, Аргумент);
		Результат = Результат И Значение1 >= Значение2;
		Значение1 = Значение2;
		Аргумент = Аргумент.Следующий;
	КонецЦикла;
	Возврат Результат;
КонецФункции // БольшеИлиРавно()

Функция МеньшеИлиРавно(Знач Окружение, Знач Аргумент)
	Перем Значение1, Значение2;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение1 = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Следующий;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Результат = Истина;
	Пока Аргумент <> Неопределено И Результат Цикл
		Значение2 = Интерпретировать(Окружение, Аргумент);
		Результат = Результат И Значение1 <= Значение2;
		Значение1 = Значение2;
		Аргумент = Аргумент.Следующий;
	КонецЦикла;
	Возврат Результат;
КонецФункции // МеньшеИлиРавно()

Функция НеРавно(Знач Окружение, Знач Аргумент)
	Перем Значение1, Значение2;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение1 = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Следующий;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Результат = Истина;
	Пока Аргумент <> Неопределено И Результат Цикл
		Значение2 = Интерпретировать(Окружение, Аргумент);
		Результат = Результат И Значение1 <> Значение2;
		Значение1 = Значение2;
		Аргумент = Аргумент.Следующий;
	КонецЦикла;
	Возврат Результат;
КонецФункции // НеРавно()

Функция ВывестиСообщение(Знач Окружение, Знач Аргумент)
	Перем Значения;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значения = Новый Массив;
	Пока Аргумент <> Неопределено Цикл
		Значения.Добавить(Интерпретировать(Окружение, Аргумент));
		Аргумент = Аргумент.Следующий;
	КонецЦикла;
	Сообщить(СтрСоединить(Значения, " "));
	Возврат Неопределено;
КонецФункции // ВывестиСообщение

Функция Интерпретировать(Знач Окружение, Знач Список) Экспорт
	Перем Тип, Данные;
	Тип = Список.Тип; Данные = Список.Данные;
	Если Тип = "Объект" Тогда
		Если Данные = "Функция" Тогда
			Возврат ОпределениеФункции(Окружение, Список.Следующий);
		ИначеЕсли Данные = "Если" Тогда
			Возврат ЗначениеВыраженияЕсли(Окружение, Список.Следующий);
		ИначеЕсли Данные = "Сообщить" Тогда
			Возврат ВывестиСообщение(Окружение, Список.Следующий);
		ИначеЕсли Данные = "+" Тогда
			Возврат Сумма(Окружение, Список.Следующий);
		ИначеЕсли Данные = "-" Тогда
			Возврат Разность(Окружение, Список.Следующий);
		ИначеЕсли Данные = "*" Тогда
			Возврат Произведение(Окружение, Список.Следующий);
		ИначеЕсли Данные = "/" Тогда
			Возврат Частное(Окружение, Список.Следующий);
		ИначеЕсли Данные = "%" Тогда
			Возврат Остаток(Окружение, Список.Следующий);
		ИначеЕсли Данные = "=" Тогда
			Возврат Равно(Окружение, Список.Следующий);
		ИначеЕсли Данные = ">" Тогда
			Возврат Больше(Окружение, Список.Следующий);
		ИначеЕсли Данные = "<" Тогда
			Возврат Меньше(Окружение, Список.Следующий);
		ИначеЕсли Данные = ">=" Тогда
			Возврат БольшеИлиРавно(Окружение, Список.Следующий);
		ИначеЕсли Данные = "<=" Тогда
			Возврат МеньшеИлиРавно(Окружение, Список.Следующий);
		ИначеЕсли Данные = "<>" Тогда
			Возврат НеРавно(Окружение, Список.Следующий);
		ИначеЕсли Данные = "Истина" Тогда
			Возврат Истина;
		ИначеЕсли Данные = "Ложь" Тогда
			Возврат Ложь;
		Иначе
			ЭлементОкружения = ЭлементОкружения(Окружение, Список.Данные);
			Если ТипЗнч(ЭлементОкружения) = Тип("ФиксированнаяСтруктура") Тогда
				Если ЭлементОкружения.Тип = "Функция" Тогда
					Возврат ЗначениеФункции(Окружение, ЭлементОкружения, Список.Следующий);
				Иначе
					ВызватьИсключение "Неизвестный объект";
				КонецЕсли;
			Иначе
				Возврат ЭлементОкружения;
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли Тип = "Число" Тогда
		Возврат Число(Данные);
	ИначеЕсли Тип = "Строка" Тогда
		Возврат Данные;
	Иначе // Список
		Возврат Интерпретировать(Окружение, Данные);
	КонецЕсли;
КонецФункции // Интерпретировать()

#КонецОбласти // Интерпретатор

Функция Пуск(Знач Исходник) Экспорт
	Перем Парсер, Список, Результат;
	Парсер = Парсер(Исходник);
	Список = Разобрать(Парсер);
	Результат = Новый Массив;
	ОткрытьОкружение(Парсер.Окружение);
	Пока Список <> Неопределено Цикл
		Значение = Интерпретировать(Парсер.Окружение, Список);
		Если Значение <> Неопределено Тогда
			Результат.Добавить(Значение);
		КонецЕсли;
		Список = Список.Следующий;
	КонецЦикла;
	ЗакрытьОкружение(Парсер.Окружение);
	Возврат СтрСоединить(Результат, Символы.ПС);
КонецФункции // Пуск()

Инициализировать();