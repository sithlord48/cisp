/*
    Cisp -- Common Input Sharing Parts
    Copyright (C) 2024 Cisp Developers
    Copyright (C) InputLeap contributors

    This package is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    found in the file LICENSE that should have accompanied this file.

    This package is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "EventTarget.h"
#include "IEventQueue.h"

namespace cisp {

EventTarget::EventTarget() = default;

EventTarget::~EventTarget()
{
    if (event_queue_ != nullptr) {
        event_queue_->remove_handlers(this);
    }
}

} // namespace cisp
