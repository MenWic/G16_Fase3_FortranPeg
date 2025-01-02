// Generar clases para CST
// Este archivo genera las clases necesarias para implementar el patrón visitante, usando JsDoc
// porque no nos dejan usar typescript

import { writeFileSync } from 'node:fs';
import path from 'node:path';
import nodes from './Nodes.js';

const __dirname = import.meta.dirname;
const classesDestination = '../src/visitor/CST.js';
const visitorDestination = '../src/visitor/Visitor.js';

let codeString = `
// Auto-generated

/** @typedef {import('./Node.js').default} Node*/
/**
 * @typedef {{
 *  [rule: string]: string
 * }} ActionTypes
 */

/**
 * @interface
 * @template T
 */
export default class Visitor {
    /**
     * Table that contains the function identifier for a rule's choices
     * and their fortran return type.
     * If a rule's choice doesn't have an entry in the table, it means
     * it doesn't have an action associated with it and should
     * be interpreted as having a character(len=:) return type by default.
     * @type {ActionTypes}
     */
    actionReturnTypes;
    /**
     * List with all the actions' code.
     * @type {string[]}
     */
    actions
    /**
     * Wheter we are traversing the starting rule or not.
     * @type {boolean}
     */
    translatingStart;
    /**
     * Id of the current rule we are traversing.
     * @type {string}
     */
    currentRule;
    /**
     * A rule can have many choices (e.g., rule = a/b/c). This variable stores
     * the index of the current choice in the current rule.
     * @type {number}
     */
    currentChoice;
    /**
     * A choice can have many expresions (e.g., rule = abc). This variable stores
     * the index of the current expression in the current choice.
     * @type {number}
     */
    currentExpr;

    ${Object.keys(nodes)
        .map(
            (node) => `
    /**
     * @abstract
     * @param {Node} node
     * @returns {T}
     */
    visit${node}(node){
        throw new Error('Implement in subclass');
    }`
        )
        .join('\n\t')}
}
`;
writeFileSync(path.join(__dirname, visitorDestination), codeString);
console.log('Generated visitor Interface');

codeString = `
// Auto-generated

/**
 * @template T
 * @typedef {import('./Visitor.js').default<T>} Visitor
 */
/**
 * @typedef {import('./Node.js').default} Node
 */

${Object.entries(nodes)
    .map(([node, args]) => {
        const declaration = `
/**
 * @implements {Node}
 */
export class ${node} {
    /**
     *
    ${Object.entries(args)
        .map(
            ([arg, type]) =>
                ` * @param {${
                    type.startsWith('?') ? type.slice(1) + '=' : type
                }} ${arg}`
        )
        .join('\n\t')}
     */
    constructor(${Object.keys(args).join(', ')}) {
        ${Object.keys(args)
            .map((arg) => `this.${arg} = ${arg};`)
            .join('\n\t\t')}
    }

    /**
     * @template T
     * @param {Visitor<T>} visitor
     * @returns {T}
     */
    accept(visitor) {
        return visitor.visit${node}(this);
    }
}
    `;
        console.log(`Generated ${node} class`);
        return declaration;
    })
    .join('\n')}
`;

writeFileSync(path.join(__dirname, classesDestination), codeString);
console.log('Done!');
