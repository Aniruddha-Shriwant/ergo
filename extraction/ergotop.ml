(*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *)

open ErgoComp
open ParseString
open Unix

let get_stdlib () =
  List.map (ParseString.parse_ergo_module_from_string "stdlib") (List.map snd ErgoStdlib.ergo_stdlib)

let get_ctos () =
  ErgoConfig.get_ctos (ErgoConfig.default_config ())

let string_of_char_list cl = String.concat "" (List.map (String.make 1) cl)

let welcome () =
    if isatty stdin
    then print_string ("Welcome to ERGOTOP version " ^ (string_of_char_list ergo_version) ^ "\n")
    else ()

let prompt () =
    if isatty stdin then
        print_string "ergotop$ "
    else ()

let rec repl ctx =
    prompt () ;
    try
        let t = (ParseString.parse_ergo_module_from_string "stdin"
                ("namespace org.accordproject.repl\n" ^
                (read_line ()) ^
                "\n")) in
        let ctos = get_ctos () in
        let ml = get_stdlib () in
        let result = ergo_eval_module ctos ml ctx t in
        let out = ergo_string_of_result result in
        if (List.length out) > 0
        then print_string ((string_of_char_list out) ^ "\n")
        else ();
        repl (ergo_maybe_update_context ctx result)
    with
    | ErgoUtil.Ergo_Error e ->
        print_string (ErgoUtil.string_of_error e);
        print_string "\n" ;
        repl ctx
    | End_of_file -> None

let main =
    welcome ();
    repl ergo_empty_context