// The drawing surface of the web game: a small stand-in for SpriteKit.
//
// A Stage holds nodes, which are drawn back to front by their z. Positions are in the layout's logical
// coordinates, the same numbers as the iOS game: the origin is the bottom left and y goes up. Each node is
// drawn with the canvas moved to its position (and y turned the right way up), so a node draws itself
// around 0,0 in ordinary canvas coordinates, y down.
//
// Nothing in this file touches the page, so it can be tested without a browser.

/** Something on the stage. Subclasses draw themselves in drawSelf(ctx) and say what a pointer can hit in contains() */
export class Node {
    constructor() {
        this.x = 0;
        this.y = 0;
        this.z = 0;
        this.alpha = 1;
        this.scale = 1;
        /** Radians, anticlockwise as in SpriteKit */
        this.rotation = 0;
        this.visible = true;
        this.name = null;
        this.stage = null;
        /** Set to handle a press: onDown(x, y) when the pointer goes down on the node */
        this.onDown = null;
        /** Set to handle a click: onPressed() when the pointer went down on the node and came up on it */
        this.onPressed = null;
    }

    at(pos) {
        this.x = pos.x;
        this.y = pos.y;
        return this;
    }

    /** Is the point, in the node's own coordinates (y down, before scale and rotation), inside the node? */
    contains(x, y) {
        return false;
    }

    /** Draw around 0,0, y down */
    drawSelf(ctx, stage) {}

    /** Called every frame with the seconds since the last one */
    update(dt) {}

    /** The pointer went down on the node, came up on it, or left it without coming up */
    pressChanged(isPressed) {}

    remove() {
        this.stage?.remove(this);
    }
}

export const Ease = Object.freeze({
    linear: t => t,
    inOut: t => t * t * (3 - 2 * t),
});

/**
 * Nodes, and the animations running on them.
 * size: the logical width and height, from the layout
 */
export class Stage {
    constructor(size) {
        this.size = size;
        this.nodes = [];
        this.tweens = [];
        this.timers = [];
        this.pressed = null;
        this.order = 0;
    }

    add(node) {
        node.stage = this;
        node.order = this.order++;
        this.nodes.push(node);
        return node;
    }

    remove(node) {
        this.nodes = this.nodes.filter(other => other !== node);
        this.tweens = this.tweens.filter(tween => tween.node !== node);
        if (this.pressed === node) {
            this.pressed = null;
        }
        node.stage = null;
    }

    find(name) {
        return this.nodes.find(node => node.name === name) ?? null;
    }

    /** Back to front: by z, nodes with the same z in the order they were added */
    get sorted() {
        return [...this.nodes].sort((a, b) => a.z - b.z || a.order - b.order);
    }

    //MARK: - Animation

    /**
     * Changes numeric properties of a node smoothly: stage.animate(card, {x: 10, y: 20}, 0.5)
     * duration and delay are in seconds. Options:
     *   delay    seconds to wait first
     *   ease     an Ease function
     *   yoyo     go there and back again
     *   repeat   how many more times to do it, Infinity for ever
     *   then     called when it has finished
     * An animation replaces any other that is changing the same property of the node, once it starts.
     */
    animate(node, to, duration, { delay = 0, ease = Ease.inOut, yoyo = false, repeat = 0, then = null } = {}) {
        const tween = { node, to, duration, delay, ease, yoyo, repeat, then, elapsed: 0, from: null };
        this.tweens.push(tween);
        if (delay <= 0) {
            this.start(tween);
        }
        return tween;
    }

    start(tween) {
        tween.from = {};
        for (const key of Object.keys(tween.to)) {
            tween.from[key] = tween.node[key];
        }
        //Take over from older animations of the same properties
        for (const other of this.tweens) {
            if (other !== tween && other.node === tween.node && other.from !== null) {
                for (const key of Object.keys(tween.to)) {
                    delete other.to[key];
                }
            }
        }
        this.tweens = this.tweens.filter(other => other === tween || Object.keys(other.to).length > 0);
    }

    /** Stops the animations of a node, leaving it as it is now */
    stopAnimations(node) {
        this.tweens = this.tweens.filter(tween => tween.node !== node);
    }

    /** Calls the function after the seconds have passed */
    after(seconds, action) {
        this.timers.push({ remaining: seconds, action });
    }

    /** Moves everything on by dt seconds */
    update(dt) {
        for (const tween of [...this.tweens]) {
            if (!this.tweens.includes(tween)) {
                continue;
            }
            let time = dt;
            if (tween.from === null) {
                tween.delay -= dt;
                if (tween.delay > 0) {
                    continue;
                }
                time = -tween.delay;
                this.start(tween);
            }
            tween.elapsed += time;
            const cycle = tween.yoyo ? tween.duration * 2 : tween.duration;
            let finished = false;
            if (tween.elapsed >= cycle) {
                if (tween.repeat > 0) {
                    tween.repeat -= 1;
                    tween.elapsed -= cycle;
                } else {
                    tween.elapsed = cycle;
                    finished = true;
                }
            }
            let t = tween.duration > 0 ? tween.elapsed / tween.duration : 1;
            if (tween.yoyo && t > 1) {
                t = 2 - t;
            }
            t = tween.ease(Math.max(0, Math.min(1, t)));
            for (const key of Object.keys(tween.to)) {
                tween.node[key] = tween.from[key] + (tween.to[key] - tween.from[key]) * t;
            }
            if (finished) {
                this.tweens = this.tweens.filter(other => other !== tween);
                tween.then?.();
            }
        }
        for (const timer of [...this.timers]) {
            timer.remaining -= dt;
            if (timer.remaining <= 0) {
                this.timers = this.timers.filter(other => other !== timer);
                timer.action();
            }
        }
        for (const node of [...this.nodes]) {
            node.update(dt);
        }
    }

    //MARK: - Pointer

    /** A logical point in the node's own coordinates: y down, with its scale and rotation undone */
    toLocal(node, x, y) {
        let dx = (x - node.x) / node.scale;
        let dy = -(y - node.y) / node.scale;
        if (node.rotation !== 0) {
            const cos = Math.cos(node.rotation), sin = Math.sin(node.rotation);
            [dx, dy] = [dx * cos - dy * sin, dx * sin + dy * cos];
        }
        return { x: dx, y: dy };
    }

    /** The front most node at the logical point that takes presses, or null. A node with blocksPointer hides those behind it */
    nodeAt(x, y) {
        for (const node of this.sorted.reverse()) {
            if (!node.visible) {
                continue;
            }
            const local = this.toLocal(node, x, y);
            if (node.contains(local.x, local.y)) {
                if (node.onDown || node.onPressed || node.blocksPointer) {
                    return node;
                }
            }
        }
        return null;
    }

    pointerDown(x, y) {
        const node = this.nodeAt(x, y);
        this.pressed = node;
        if (node) {
            const local = this.toLocal(node, x, y);
            node.pressChanged(true);
            node.onDown?.(local.x, local.y);
        }
    }

    pointerUp(x, y) {
        const node = this.pressed;
        this.pressed = null;
        if (node && node.stage === this) {
            node.pressChanged(false);
            if (this.nodeAt(x, y) === node) {
                node.onPressed?.();
            }
        }
    }

    pointerCancel() {
        this.pressed?.pressChanged(false);
        this.pressed = null;
    }

    //MARK: - Drawing

    /** Draws the nodes. The context is already scaled so that one unit is one logical point, origin top left */
    draw(ctx) {
        for (const node of this.sorted) {
            if (!node.visible || node.alpha <= 0) {
                continue;
            }
            ctx.save();
            ctx.translate(node.x, this.size.height - node.y);
            if (node.rotation !== 0) {
                ctx.rotate(-node.rotation);
            }
            if (node.scale !== 1) {
                ctx.scale(node.scale, node.scale);
            }
            ctx.globalAlpha = Math.max(0, Math.min(1, node.alpha));
            node.drawSelf(ctx, this);
            ctx.restore();
        }
    }
}
