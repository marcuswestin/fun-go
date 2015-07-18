package colors

func color(color, str string) string { return "\u001b[" + color + "m" + str + "\u001b[0m" }
func Red(str string) string          { return color("31", str) }
func Green(str string) string        { return color("32", str) }
func Yellow(str string) string       { return color("33", str) }
func Blue(str string) string         { return color("34", str) }
func Magenta(str string) string      { return color("35", str) }
func Cyan(str string) string         { return color("36", str) }
func Black(str string) string        { return color("30", str) }
func RedLight(str string) string     { return color("91", str) }
func BgWhite(str string) string      { return color("107", str) }
