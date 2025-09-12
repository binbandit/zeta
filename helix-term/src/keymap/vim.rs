use std::collections::HashMap;

use super::macros::keymap;
use super::{KeyTrie, Mode};
use helix_core::hashmap;

pub fn vim_default() -> HashMap<Mode, KeyTrie> {
    let normal = keymap!({ "Normal mode"
        // Movement
        "h" | "left" => move_char_left,
        "j" | "down" => move_visual_line_down,
        "k" | "up" => move_visual_line_up,
        "l" | "right" => move_char_right,
        
        // Word movement
        "w" => move_next_word_start,
        "b" => move_prev_word_start,
        "e" => move_next_word_end,
        "W" => move_next_long_word_start,
        "B" => move_prev_long_word_start,
        "E" => move_next_long_word_end,
        
        // Line movement
        "0" => goto_line_start,
        "^" => goto_first_nonwhitespace,
        "$" => goto_line_end,
        "g" => { "Goto"
            "g" => goto_file_start,
            "e" => goto_last_line,
            "h" => goto_line_start,
            "l" => goto_line_end,
        },
        "G" => goto_line,
        
        // Search
        "/" => search,
        "?" => reverse_search,
        "n" => search_next,
        "N" => search_prev,
        
        // Character search
        "f" => find_next_char,
        "F" => find_prev_char,
        "t" => find_till_char,
        "T" => till_prev_char,
        ";" => repeat_last_motion,
        "," => repeat_last_motion_reverse,
        
        // Insert modes
        "i" => insert_mode,
        "I" => insert_at_line_start,
        "a" => append_mode,
        "A" => insert_at_line_end,
        "o" => open_below,
        "O" => open_above,
        
        // Visual mode
        "v" => select_mode,
        "V" => select_line_mode,
        
        // Editing
        "x" => delete_selection,
        "d" => delete_selection,
        "c" => change_selection,
        "y" => yank,
        "p" => paste_after,
        "P" => paste_before,
        
        // Undo/redo
        "u" => undo,
        "C-r" => redo,
        
        // Replace
        "r" => replace,
        "R" => replace_with_yanked,
        
        // Case changes
        "~" => switch_case,
        
        // Command mode
        ":" => command_mode,
        
        // Screen movement
        "C-f" => page_down,
        "C-b" => page_up,
        "C-d" => half_page_down,
        "C-u" => half_page_up,
        
        // Other
        "esc" => normal_mode,
        "zz" => align_view_center,
        "zt" => align_view_top,
        "zb" => align_view_bottom,
    });
    
    let insert = keymap!({ "Insert mode"
        "esc" => normal_mode,
        "C-c" => normal_mode,
        "C-[" => normal_mode,
        
        // Movement in insert mode
        "left" => move_char_left,
        "right" => move_char_right,
        "up" => move_visual_line_up,
        "down" => move_visual_line_down,
        "home" => goto_line_start,
        "end" => goto_line_end,
        
        // Deletion in insert mode
        "backspace" => delete_char_backward,
        "delete" => delete_char_forward,
        "C-w" => delete_word_backward,
        "C-u" => delete_to_line_start,
    });
    
    let select = keymap!({ "Select mode"
        "esc" => normal_mode,
        "C-c" => normal_mode,
        
        // Movement
        "h" | "left" => extend_char_left,
        "j" | "down" => extend_line_down,
        "k" | "up" => extend_line_up,
        "l" | "right" => extend_char_right,
        
        "w" => extend_next_word_start,
        "b" => extend_prev_word_start,
        "e" => extend_next_word_end,
        
        "0" => extend_to_line_start,
        "$" => extend_to_line_end,
        
        // Actions
        "x" => delete_selection,
        "d" => delete_selection,
        "c" => change_selection,
        "y" => yank_selection,
    });
    
    hashmap! {
        Mode::Normal => normal,
        Mode::Insert => insert,
        Mode::Select => select,
    }
}