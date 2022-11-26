/*
Borg backup runner. Wrapper script for basic borg backup features.
Copyright (C) 2022  Twilight Sparkle

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

try {
    result = {
        empty: false,
        msgtype: data.notify ? 'm.text' : 'm.notice',
        plain: `${data.notify ? '@room ' : ''}${data.text}`,
        version: 'v2',
    };
} catch (error) {
    const obj = {
        error,
        data,
    };
    result = {
        empty: false,
        msgtype: 'm.text',
        plain: `\`\`\`json\n${JSON.stringify(obj, null, 4)}\n\`\`\``,
        version: 'v2',
    };
}
