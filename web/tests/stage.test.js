// The stage: animations, timers, drawing order and which node a press lands on. No browser is needed for these
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { Ease, Node, Stage } from '../js/view/stage.js';

/** A square node of the given size, centred on its position */
class Box extends Node {
    constructor(size = 10) {
        super();
        this.size = size;
    }
    contains(x, y) {
        return Math.abs(x) <= this.size / 2 && Math.abs(y) <= this.size / 2;
    }
}

function createStage() {
    return new Stage({ width: 200, height: 100 });
}

test('animate: moves a property to its target over the duration, then calls then', () => {
    const stage = createStage();
    const node = stage.add(new Box());
    let done = 0;
    stage.animate(node, { x: 100, alpha: 0 }, 2, { ease: Ease.linear, then: () => { done += 1; } });
    stage.update(0.5);
    assert.equal(node.x, 25);
    assert.equal(node.alpha, 0.75);
    assert.equal(done, 0);
    stage.update(1.5);
    assert.equal(node.x, 100);
    assert.equal(node.alpha, 0);
    assert.equal(done, 1);
    stage.update(1);
    assert.equal(done, 1);
    assert.equal(stage.tweens.length, 0);
});

test('animate: a delay, and the start value is taken when the delay is over', () => {
    const stage = createStage();
    const node = stage.add(new Box());
    stage.animate(node, { x: 100 }, 1, { delay: 1, ease: Ease.linear });
    stage.update(0.5);
    assert.equal(node.x, 0);
    node.x = 50;
    stage.update(1.0);
    assert.equal(node.x, 75);
    stage.update(1.0);
    assert.equal(node.x, 100);
});

test('animate: a later animation takes over the property, others carry on', () => {
    const stage = createStage();
    const node = stage.add(new Box());
    stage.animate(node, { x: 100, y: 100 }, 1, { ease: Ease.linear });
    stage.update(0.5);
    stage.animate(node, { x: 0 }, 1, { ease: Ease.linear });
    stage.update(0.5);
    assert.equal(node.x, 25);
    assert.equal(node.y, 100);
    stage.update(0.5);
    assert.equal(node.x, 0);
});

test('animate: yoyo goes there and back, repeat does it again', () => {
    const stage = createStage();
    const node = stage.add(new Box());
    let done = false;
    stage.animate(node, { scale: 2 }, 1, { ease: Ease.linear, yoyo: true, repeat: 1, then: () => { done = true; } });
    stage.update(1);
    assert.equal(node.scale, 2);
    stage.update(0.5);
    assert.equal(node.scale, 1.5);
    stage.update(1);
    assert.equal(node.scale, 1.5);
    assert.equal(done, false);
    stage.update(1.5);
    assert.equal(node.scale, 1);
    assert.equal(done, true);
});

test('animate: stops when the node is removed or its animations are stopped', () => {
    const stage = createStage();
    const a = stage.add(new Box());
    const b = stage.add(new Box());
    stage.animate(a, { x: 100 }, 1, { ease: Ease.linear, repeat: Infinity });
    stage.animate(b, { x: 100 }, 1, { ease: Ease.linear });
    stage.update(0.5);
    stage.stopAnimations(a);
    b.remove();
    stage.update(0.5);
    assert.equal(a.x, 50);
    assert.equal(b.x, 50);
    assert.equal(b.stage, null);
    assert.deepEqual(stage.nodes, [a]);
});

test('after: calls the function once the time has passed', () => {
    const stage = createStage();
    let calls = 0;
    stage.after(1, () => { calls += 1; });
    stage.update(0.9);
    assert.equal(calls, 0);
    stage.update(0.2);
    stage.update(5);
    assert.equal(calls, 1);
});

test('Drawing order: by z, then the order added', () => {
    const stage = createStage();
    const a = stage.add(new Box()), b = stage.add(new Box()), c = stage.add(new Box());
    a.z = 5;
    assert.deepEqual(stage.sorted, [b, c, a]);
    assert.equal(stage.find('none'), null);
    b.name = 'bee';
    assert.equal(stage.find('bee'), b);
});

test('Pointer: the front most node that takes presses is hit, y goes up', () => {
    const stage = createStage();
    const back = stage.add(new Box(20)), front = stage.add(new Box(20)), decoration = stage.add(new Box(20));
    const downs = [];
    back.at({ x: 50, y: 70 }).onDown = (x, y) => downs.push(['back', x, y]);
    front.at({ x: 60, y: 70 }).onDown = (x, y) => downs.push(['front', x, y]);
    decoration.at({ x: 60, y: 70 }).z = 9;
    //Where both are, the one added last is in front. The decoration takes no presses, so is passed through
    stage.pointerDown(55, 72);
    //Only the back one is here. A point above the node's centre has a negative y in its own coordinates
    stage.pointerDown(42, 78);
    stage.pointerDown(150, 20);
    assert.deepEqual(downs, [['front', -5, -2], ['back', -8, -8]]);
    back.z = 3;
    stage.pointerDown(55, 72);
    assert.equal(downs.at(-1)[0], 'back');
    front.visible = false;
    assert.equal(stage.nodeAt(68, 70), null);
});

test('Pointer: onPressed needs the press to end on the node it started on, a blocking node hides those behind', () => {
    const stage = createStage();
    const button = stage.add(new Box(20));
    let pressed = 0;
    const states = [];
    button.at({ x: 50, y: 50 }).onPressed = () => { pressed += 1; };
    button.pressChanged = isPressed => states.push(isPressed);
    stage.pointerDown(50, 50);
    stage.pointerUp(52, 48);
    assert.equal(pressed, 1);
    stage.pointerDown(50, 50);
    stage.pointerUp(150, 50);
    assert.equal(pressed, 1);
    stage.pointerUp(50, 50);
    assert.equal(pressed, 1);
    assert.deepEqual(states, [true, false, true, false]);
    //A scaled node is hit over its scaled size
    button.scale = 3;
    assert.equal(stage.nodeAt(75, 50), button);
    button.scale = 1;

    const panel = stage.add(new Box(100));
    panel.at({ x: 50, y: 50 }).blocksPointer = true;
    stage.pointerDown(50, 50);
    stage.pointerUp(50, 50);
    assert.equal(pressed, 1);
});
