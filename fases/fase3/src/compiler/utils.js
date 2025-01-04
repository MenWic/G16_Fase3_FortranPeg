import FortranTranslator from './Translator.js';

/** @typedef {import('../visitor/CST.js').Grammar} Grammar*/
/** @typedef {import('../visitor/Visitor.js').default<string>} Visitor*/
/** @typedef {import('../visitor/Visitor.js').ActionTypes} ActionTypes*/

/**
 *
 * @param {Grammar} cst
 */
export async function generateParser(cst) {
    /** @type {ActionTypes} */
    const ruleReturnTypes = {};
    for (const rule of cst.rules) {
        rule.expr.exprs.forEach((concat, i) => {
            if (concat.action) {
                const functionId = `peg_${rule.id}_f${i}`;
                ruleReturnTypes[functionId] = concat.action.returnType;
            }
        });
    }

    /** @type {Visitor} */
    const translator = new FortranTranslator(ruleReturnTypes);
    return cst.accept(translator);
}

/**
 *
 * @param {string} ruleId
 * @param {number} choice
 * @returns
 */
export function getActionId(ruleId, choice) {
    return `peg_${ruleId}_f${choice}`;
}

/**
 *
 * @param {string} functionId
 * @param {ActionTypes} actionReturnTypes
 * @returns
 */
export function getReturnType(functionId, actionReturnTypes) {
    return actionReturnTypes[functionId] ?? 'character(len=:), allocatable';
}

/**
 *
 * @param {number} choice
 * @param {number} index
 * @returns
 */
export function getExprId(choice, index) {
    return `expr_${choice}_${index}`;
}

/**
 *
 * @param {string} rule
 * @returns
 */
export function getRuleId(rule) {
    return `peg_${rule}`;
}
