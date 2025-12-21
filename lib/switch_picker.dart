import 'dart:io';
import 'command.dart';
import 'colors.dart' as colors;

/// Provides interactive terminal menu for selecting a switch case.
class SwitchPicker {
  /// Shows an interactive menu to select a switch case from the given command.
  /// Returns the selected switch name or null if cancelled.
  static String? pick(Command command, String commandPath) {
    if (command.switches.isEmpty) {
      return null;
    }

    final switchNames = command.switches.keys.toList();
    int selectedIndex = 0; // Currently selected option (0-based)

    // Calculate max switch name length for alignment
    int maxSwitchNameLength = 0;
    for (final switchName in switchNames) {
      if (switchName.length > maxSwitchNameLength) {
        maxSwitchNameLength = switchName.length;
      }
    }

    // Helper function to display the menu
    void displayMenu() {
      print('');
      print('Select an option for ${colors.blue}$commandPath${colors.reset}:');
      print('');

      for (var i = 0; i < switchNames.length; i++) {
        final switchName = switchNames[i];
        final switchInfo = command.getSwitchInfo(switchName);
        final number = i + 1;
        final isSelected = i == selectedIndex;
        final checkMark = isSelected ? ' ✓' : '  '; // Always 2 chars width

        // Pad switch name to align everything
        final paddedSwitchName = switchName.padRight(maxSwitchNameLength);

        // Build display string
        String display = isSelected
            ? '    ${colors.green}$number. $paddedSwitchName$checkMark${colors.reset}'
            : '    $number. $paddedSwitchName$checkMark';

        // Add flags if available
        if (switchInfo != null && switchInfo.flags != null && switchInfo.flags!.isNotEmpty) {
          display += ' ${colors.gray}or: [${switchInfo.flags}]${colors.reset}';
        }

        // Add description if available
        if (switchInfo != null && switchInfo.description != null) {
          display += ' ${colors.gray}- ${switchInfo.description}${colors.reset}';
        }

        print(display);
      }

      print('');
      print('${colors.gray}Press number (1-${switchNames.length}) or press Esc to cancel:${colors.reset}');
    }

    // Display initial menu
    displayMenu();

    // Enable raw mode to detect arrow keys and ESC
    stdin.echoMode = false;
    stdin.lineMode = false;

    while (true) {
      final charCode = stdin.readByteSync();

      // ESC key (27) - check if it's part of arrow key sequence
      if (charCode == 27) {
        // Sleep briefly to see if more bytes are coming (for arrow keys)
        sleep(Duration(milliseconds: 10));

        // Check if there's more input (arrow keys send ESC[A/B/C/D)
        if (stdin.hasTerminal) {
          try {
            // Try to read next byte without blocking
            final bytesAvailable = stdin.readByteSync();

            if (bytesAvailable == 91) {
              // '[' character - this is an arrow key sequence
              final arrowChar = stdin.readByteSync();

              // Arrow Up (65 = 'A')
              if (arrowChar == 65) {
                selectedIndex = (selectedIndex - 1 + switchNames.length) % switchNames.length;
                // Clear screen and redraw
                _clearScreen(switchNames.length + 5);
                displayMenu();
                continue;
              }

              // Arrow Down (66 = 'B')
              if (arrowChar == 66) {
                selectedIndex = (selectedIndex + 1) % switchNames.length;
                // Clear screen and redraw
                _clearScreen(switchNames.length + 5);
                displayMenu();
                continue;
              }
            }
          } catch (e) {
            // No more bytes available - it's just ESC key
          }
        }

        // Just ESC key - cancel
        stdin.echoMode = true;
        stdin.lineMode = true;
        print('\n${colors.yellow}Cancelled${colors.reset}');
        return null;
      }

      // Enter key (10 or 13) - execute selected option
      if (charCode == 10 || charCode == 13) {
        stdin.echoMode = true;
        stdin.lineMode = true;
        print('');
        return switchNames[selectedIndex];
      }

      // Number keys (49-57 correspond to '1'-'9')
      if (charCode >= 49 && charCode <= 57) {
        final number = charCode - 48; // Convert to 1-9
        if (number >= 1 && number <= switchNames.length) {
          stdin.echoMode = true;
          stdin.lineMode = true;
          print('');
          return switchNames[number - 1];
        }
      }
    }
  }

  /// Clears the specified number of lines from the terminal
  static void _clearScreen(int lines) {
    for (var i = 0; i < lines; i++) {
      stdout.write('\x1B[1A'); // Move cursor up one line
      stdout.write('\x1B[2K'); // Clear entire line
    }
    stdout.write('\r'); // Move cursor to start of line
  }
}
