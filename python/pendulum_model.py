from sympy import symbols, sin, cos, diff, Eq, solve, expand, simplify, sqrt
from sympy.physics.vector import ReferenceFrame, dynamicsymbols, time_derivative, dot, cross


def strip_eq(eq):
    text = str(simplify(eq))
    text = text.replace("Derivative(q1(t), t)", "dx")
    text = text.replace("Derivative(q2(t), t)", "df")
    text = text.replace("Derivative(q1(t), (t, 2))", "ddx")
    text = text.replace("Derivative(q2(t), (t, 2))", "ddf")
    text = text.replace("q1(t)", "x")
    text = text.replace("q2(t)", "f")
    text = text.replace("1.0*", "")
    text = text.replace("**", "^")
    text = text.replace("0.707106781186548", "(1/sqrt(2))")
    text = text.replace("1.4142135623731", "sqrt(2)")
    text = text.replace("0.5", "(1/2)")
    return text + ";"


def print_eq(title, eq=None):
    if eq is None:
        title, text = "", strip_eq(title)
    else:
        title, text = title, strip_eq(eq)
    print(title, text)


def main():
    # vectors #
    R = ReferenceFrame('R')
    ex_ = R.x
    ey_ = R.y
    ez_ = R.z

    # symbols #
    m1, m2, L, g = symbols('m1, m2, L, g')
    Fc, Cd1, Cd2, b1, b2 = symbols('F, Cd1, Cd2, b1, b2')

    M = [m1, m2]
    q1, q2 = dynamicsymbols('q1, q2')

    qq = [q1, q2]
    dqq = [time_derivative(q, R) for q in qq]
    ddqq = [time_derivative(dq, R) for dq in dqq]

    L_ = L * (-sin(qq[1]) * ex_ + cos(qq[1]) * ey_)

    # velocities #
    W = [0 * ez_, dqq[1] * ez_]

    V = [
        dqq[0] * ex_,
        dqq[0] * ex_ + cross(W[1], L_)
    ]

    S = [
        sqrt(dot(V[0], V[0])),
        sqrt(dot(V[1], V[1]))
    ]

    # forces #
    F = [
        Fc * ex_ - M[0] * g * ey_ - V[0] * b1 - S[0] * V[0] * Cd1,
        -M[1] * g * ey_ - S[1] * V[1] * Cd2,
    ]

    T = [
        0 * ez_,
        -W[1] * b2
    ]

    # kinetic energy (SIMPLIFIED) #
    E = [1/2 * m * dot(v, v) for m, v in zip(M, V)]
    E_sum = sum(E)

    # Lagrangian
    DE_q = [diff(E_sum, q) for q in qq]
    DE_dq = [diff(E_sum, dq) for dq in dqq]
    d_DE_dq = [time_derivative(DE, R) for DE in DE_dq]

    left = [expand(D_dq - D_q) for D_dq, D_q in zip(d_DE_dq, DE_q)]

    # General force effect #
    Q = []
    for dq in dqq:
        Q_j = 0
        for f, v in zip(F, V):
            Q_j += dot(f, v.diff(dq, R))
        for t, w in zip(T, W):
            Q_j += dot(t, w.diff(dq, R))
        Q.append(Q_j)

    eq = [Eq(left_element, Q_element) for left_element, Q_element in zip(left, Q)]

    # substitution = (Cd1, 0), (Cd2, 0)
    substitution = set()
    eq = [e.subs(substitution) for e in eq]

    solution = solve(eq, ddqq)

    print_eq("Equation 1:", eq[0])
    print_eq("Equation 2:", eq[1])
    print()
    print_eq("ddx =", solution[ddqq[0]])
    print_eq("ddf =", solution[ddqq[1]])

if __name__ == "__main__":
    main()