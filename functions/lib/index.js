"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.manageUserStatus = exports.onMatchFinalized = void 0;
const admin = require("firebase-admin");
admin.initializeApp();
var onMatchFinalized_1 = require("./onMatchFinalized");
Object.defineProperty(exports, "onMatchFinalized", { enumerable: true, get: function () { return onMatchFinalized_1.onMatchFinalized; } });
var manageUserStatus_1 = require("./manageUserStatus");
Object.defineProperty(exports, "manageUserStatus", { enumerable: true, get: function () { return manageUserStatus_1.manageUserStatus; } });
//# sourceMappingURL=index.js.map