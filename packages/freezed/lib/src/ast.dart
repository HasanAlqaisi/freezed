import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

extension AstX on AstNode {
  String? get documentation {
    final builder = StringBuffer();

    for (
      Token? token = beginToken.precedingComments;
      token != null;
      token = token.next
    ) {
      builder.writeln(token);
    }

    if (builder.isEmpty) return null;

    return builder.toString();
  }
}

extension ClassX on ClassDeclaration {
  bool get hasCustomToString {
    final element = declaredElement!;

    for (final type in [
      element,
      ...element.allSupertypes
          .where((e) => !e.isDartCoreObject)
          .map((e) => e.element),
    ]) {
      for (final method in type.methods) {
        if (method.name == 'toString') {
          return true;
        }
      }
    }

    return false;
  }

  bool get hasCustomEquals {
    final element = declaredElement!;

    for (final type in [
      element,
      ...element.allSupertypes
          .where((e) => !e.isDartCoreObject)
          .map((e) => e.element),
    ]) {
      for (final method in type.methods.where((e) => e.isOperator)) {
        if (method.name == '==') {
          return true;
        }
      }
    }
    return false;
  }
}

extension ConstructorX on ConstructorDeclaration {
  String get fullName {
    // ignore: deprecated_member_use, latest analyzer with enclosingElement3 not available in stable channel
    final classElement = declaredElement!.enclosingElement3;

    var generics = classElement.typeParameters
        .map((e) => '\$${e.name}')
        .join(', ');
    if (generics.isNotEmpty) {
      generics = '<$generics>';
    }

    // ignore: deprecated_member_use, latest analyzer with enclosingElement3 not available in stable channel
    final className = classElement.enclosingElement3.name;

    return name == null ? '$className$generics' : '$className$generics.$name';
  }

  String get escapedName {
    // ignore: deprecated_member_use, latest analyzer with enclosingElement3 not available in stable channel
    final classElement = declaredElement!.enclosingElement3;

    var generics = classElement.typeParameters
        .map((e) => '\$${e.name}')
        .join(', ');
    if (generics.isNotEmpty) {
      generics = '<$generics>';
    }

    final escapedElementName = classElement.name.replaceAll(r'$', r'\$');
    final escapedConstructorName = name?.lexeme.replaceAll(r'$', r'\$');

    return escapedConstructorName == null
        ? '$escapedElementName$generics'
        : '$escapedElementName$generics.$escapedConstructorName';
  }
}
