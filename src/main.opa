/*  Short application implementing a REST-accessible distributed key-value store built on top of the Opa database.

    Copyright (C) 2011  MLstate

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/**
 * Short application implementing a REST-accessible distributed key-value store built on top of the Opa database.
 *
 * @author David Rajchenbach-Teller, David@opalang.org
 */

/**
 * The storage itself.
 *
 * An association from keys (strings) to values (also strings).
 */
db /storage: stringmap(option(string))

/**
 * Handle requests
 *
 * @param path The path of the request. It is converted to a key in [/storage]
 * @return If the request is rejected, [{method_not_allowed}]. If the request is a successful [{get}], a text/plain resource with the value previously stored.
 * If the request is a [{get}] to an unknown key, a [{wrong_address}]. Otherwise, a [{success}].
 */
dispatch({~path ...}): Resource.resource =
(
   key = List.to_string(path)
   match HttpRequest.get_method() with
    | {some = {get}}    ->
       match /storage[key] with
         | {none} -> Resource.raw_status({wrong_address})
         | ~{some}-> Resource.raw_response(some, "text/plain", {success})
       end
    | {some = {post}}   ->
         do /storage[key] <- HttpRequest.get_body()
         Resource.raw_status({success})
    | {some = {delete}} ->
       do Db.remove(@/storage[key])
       Resource.raw_status({success})
    | _ -> Resource.raw_status({method_not_allowed})
)

/**
 * Launch the server
 */
server = Server.simple_dispatch(dispatch)
