RegExp exp = RegExp(r'\w+ (9|10|11)');
String str = 'Parse my string 12';
var matches = exp.hasMatch('string12');

main() {
  print(matches);
}
