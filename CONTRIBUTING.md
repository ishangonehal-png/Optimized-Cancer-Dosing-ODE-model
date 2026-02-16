# Contributing to Tumor BayesOpt Project

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## How to Contribute

### Reporting Issues

If you find a bug or have a feature request:

1. **Check existing issues** to avoid duplicates
2. **Open a new issue** with:
   - Clear, descriptive title
   - Detailed description of the problem/feature
   - Steps to reproduce (for bugs)
   - Expected vs. actual behavior
   - MATLAB version and system info
   - Minimal working example if possible

### Suggesting Enhancements

For feature suggestions:

1. **Describe the use case**: What problem does this solve?
2. **Propose a solution**: How should it work?
3. **Consider alternatives**: What other approaches exist?
4. **Estimate impact**: Who would benefit from this?

### Code Contributions

#### Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Test thoroughly
5. Commit with clear messages
6. Push to your fork
7. Submit a pull request

#### Code Style

- **Follow MATLAB conventions**:
  - Use camelCase for function names
  - Use descriptive variable names
  - Add comments for complex logic
  - Include function headers with description, inputs, outputs

- **Function header template**:
  ```matlab
  function [output1, output2] = my_function(input1, input2)
  % MY_FUNCTION Brief one-line description
  %
  % Longer description explaining what the function does.
  %
  % Inputs:
  %   input1 - Description of input1
  %   input2 - Description of input2
  %
  % Returns:
  %   output1 - Description of output1
  %   output2 - Description of output2
  %
  % Example:
  %   result = my_function(x, y);
  ```

#### Testing

Before submitting:

1. **Run the main script** to ensure no errors
2. **Test edge cases** (empty data, extreme parameters)
3. **Verify outputs** match expected behavior
4. **Check performance** (avoid major slowdowns)

#### Documentation

- Update README.md if adding features
- Add comments explaining *why*, not just *what*
- Include examples for new functionality
- Update function headers

## Priority Areas for Contribution

We especially welcome contributions in:

### High Priority
- [ ] Unit tests for core functions
- [ ] Input validation and error handling
- [ ] Performance optimization
- [ ] Additional visualization options
- [ ] Export functionality (CSV, Excel)

### Medium Priority
- [ ] Multi-compartment PK models
- [ ] Alternative tumor growth models (logistic, exponential)
- [ ] Parameter sensitivity analysis
- [ ] Confidence intervals on predictions
- [ ] Batch processing for multiple datasets

### Nice to Have
- [ ] GUI interface
- [ ] Real-time plotting during optimization
- [ ] Parallel Bayesian optimization
- [ ] Integration with clinical data formats
- [ ] Automated report generation

## Scientific Contributions

### Model Extensions

If proposing a new biological model:

1. **Provide references**: Cite relevant literature
2. **Explain assumptions**: What are the modeling choices?
3. **Validate against data**: Show it fits experimental results
4. **Compare to existing**: When would you use this vs. Gompertz?

### Algorithm Improvements

For optimization algorithm changes:

1. **Benchmark performance**: Compare to baseline
2. **Explain trade-offs**: Speed vs. accuracy
3. **Provide theory**: Why should this work better?
4. **Test robustness**: Does it work across different datasets?

## Review Process

1. **Automated checks**: Code must run without errors
2. **Peer review**: At least one maintainer approval
3. **Testing**: Verify on multiple MATLAB versions if possible
4. **Documentation**: Ensure README/comments are updated
5. **Merge**: Squash commits if necessary

## Code of Conduct

Be respectful and constructive:
- Welcome newcomers
- Provide helpful feedback
- Focus on ideas, not people
- Acknowledge contributions

## Questions?

Feel free to:
- Open an issue for discussion
- Email the maintainer
- Comment on existing issues/PRs

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for helping improve this project!
